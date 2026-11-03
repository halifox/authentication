import 'package:authentication/app.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/settings/settings_provider.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/device_key_store.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:screen_security/screen_security.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({
    this.database,
    this.storage,
    this.protectScreen,
    this.applyScreenProtection,
    this.now,
    super.key,
  });
  final AppDatabase? database;
  final FlutterSecureStorage? storage;
  final Future<void> Function()? protectScreen;
  final Future<void> Function(bool)? applyScreenProtection;
  final DateTime Function()? now;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap>
    with WidgetsBindingObserver {
  final password = TextEditingController();
  late final AppDatabase db;
  late final FlutterSecureStorage storage;
  SharedPreferences? preferences;
  bool locked = false;
  bool busy = true;
  bool failed = false;
  bool unavailable = false;
  bool obscured = true;
  bool handedOff = false;
  bool sessionLocked = false;
  bool covered = false;
  bool foreground = true;
  DateTime? hiddenAt;
  Stopwatch? hiddenElapsed;
  int lifecycleGeneration = 0;
  bool protectionGate = true;
  Future<void> protectionQueue = Future.value();

  Future<void> _applyScreenProtection(bool enabled) {
    final next = protectionQueue.then((_) async {
      final effective = enabled || protectionGate;
      if (widget.applyScreenProtection != null) {
        await widget.applyScreenProtection!(effective);
      } else if (widget.protectScreen != null) {
        if (effective) await widget.protectScreen!();
      } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        final security = ScreenSecurity();
        if (effective) {
          await security.enable();
        } else {
          await security.disable();
        }
      }
    });
    protectionQueue = next.catchError((Object _) {});
    return next;
  }

  Future<void> _restoreScreenProtection() async {
    protectionGate = false;
    final settings = await db.getSettings();
    await _applyScreenProtection(settings[screenProtectionKey] ?? true);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    db = widget.database ?? AppDatabase();
    storage =
        widget.storage ??
        const FlutterSecureStorage(
          mOptions: MacOsOptions(usesDataProtectionKeychain: false),
        );
    _start();
  }

  Future<void> _start() async {
    try {
      final needsPassword = await DeviceKeyStore(
        db,
        storage,
      ).requiresPassword();
      if (needsPassword) {
        await _applyScreenProtection(true);
        if (mounted) {
          setState(() {
            locked = true;
            busy = false;
          });
        }
      } else {
        await _open(null);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          unavailable = true;
          busy = false;
        });
      }
    }
  }

  Future<void> _open(String? value) async {
    try {
      if (preferences != null) {
        final valid =
            value != null && await db.encryption.verifyPassword(value);
        if (!valid) throw const FormatException();
        if (!foreground) {
          if (mounted) setState(() => busy = false);
          return;
        }
        password.clear();
        if (mounted) setState(() => covered = true);
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) return;
        if (!foreground) {
          setState(() => busy = false);
          return;
        }
        await _restoreScreenProtection();
        if (mounted) {
          setState(() {
            sessionLocked = false;
            covered = !foreground;
            failed = false;
            busy = false;
          });
        }
        return;
      }
      final encryption = await EncryptionService.initialize(
        db,
        storage: storage,
        password: value,
      );
      final prefs = await SharedPreferences.getInstance();
      await db.initializeSettings({
        for (final setting in defaultSettings.entries)
          setting.key: prefs.getBool(setting.key) ?? setting.value,
      });
      db.encryption = encryption;
      protectionGate = false;
      if (mounted) {
        password.clear();
        setState(() {
          preferences = prefs;
          busy = false;
          locked = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          busy = false;
          if (foreground) covered = false;
          if (value == null || error is! FormatException) {
            unavailable = true;
            locked = false;
          } else {
            failed = true;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    password.dispose();
    if (!handedOff) db.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      if (foreground) {
        FocusManager.instance.primaryFocus?.unfocus();
        foreground = false;
        protectionGate = true;
        hiddenAt = widget.now?.call() ?? DateTime.now();
        hiddenElapsed = Stopwatch()..start();
        lifecycleGeneration++;
        setState(() => covered = true);
      }
    } else if (state == AppLifecycleState.resumed && !foreground) {
      foreground = true;
      final generation = ++lifecycleGeneration;
      if (preferences == null) {
        setState(() => covered = false);
      } else {
        _checkReturn(generation);
      }
    }
  }

  Future<void> _checkReturn(int generation) async {
    try {
      final seconds = (await db.getIntegerSettings())[autoLockKey] ?? 0;
      final elapsed = hiddenElapsed?.elapsed ?? Duration.zero;
      final wall = hiddenAt == null
          ? Duration.zero
          : (widget.now?.call() ?? DateTime.now()).difference(hiddenAt!);
      final expired =
          seconds == -1 ||
          (seconds > 0 &&
              (wall.isNegative ||
                  elapsed >= Duration(seconds: seconds) ||
                  wall >= Duration(seconds: seconds)));
      final needsPassword = expired && await db.encryption.passwordEnabled;
      if (!mounted || !foreground || generation != lifecycleGeneration) return;
      if (sessionLocked || needsPassword) {
        await _applyScreenProtection(true);
      } else {
        await _restoreScreenProtection();
      }
      if (!mounted || !foreground || generation != lifecycleGeneration) return;
      setState(() {
        sessionLocked = sessionLocked || needsPassword;
        covered = false;
        unavailable = false;
        busy = false;
      });
    } catch (_) {
      if (!mounted || !foreground || generation != lifecycleGeneration) return;
      setState(() {
        sessionLocked = true;
        covered = false;
        unavailable = true;
        busy = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final prefs = preferences;
    if (prefs != null) {
      handedOff = true;
      return Stack(
        alignment: Alignment.topLeft,
        children: [
          ExcludeFocus(
            excluding: covered || sessionLocked,
            child: Offstage(
              offstage: covered || sessionLocked,
              child: ProviderScope(
                overrides: [
                  introductionPreferencesProvider.overrideWithValue(prefs),
                  screenProtectionApplyProvider.overrideWithValue(
                    _applyScreenProtection,
                  ),
                  appDatabaseProvider.overrideWith((ref) {
                    ref.onDispose(db.close);
                    return db;
                  }),
                ],
                child: const AuthApp(),
              ),
            ),
          ),
          if (covered)
            const Positioned.fill(child: ColoredBox(color: Colors.black)),
          if (!covered && sessionLocked) Positioned.fill(child: _lockScreen()),
        ],
      );
    }
    return _lockScreen();
  }

  Widget _lockScreen() {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (locale, supported) =>
          supported
              .where((item) => item.languageCode == locale?.languageCode)
              .firstOrNull ??
          const Locale('en'),
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            appBar: AppBar(title: Text(l10n.unlockTitle)),
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 480),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (unavailable) ...[
                          Text(l10n.unlockUnavailable),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: () {
                              setState(() {
                                unavailable = false;
                                busy = true;
                              });
                              if (preferences == null) {
                                _start();
                              } else {
                                _checkReturn(++lifecycleGeneration);
                              }
                            },
                            child: Text(l10n.screenProtectionRetry),
                          ),
                        ] else if (locked || sessionLocked) ...[
                          TextField(
                            controller: password,
                            obscureText: obscured,
                            enabled: !busy,
                            onSubmitted: (value) {
                              if (!busy && value.isNotEmpty) {
                                setState(() {
                                  busy = true;
                                  failed = false;
                                });
                                _open(value);
                              }
                            },
                            decoration: InputDecoration(
                              labelText: l10n.unlockPassword,
                              errorText: failed ? l10n.unlockInvalid : null,
                              suffixIcon: IconButton(
                                tooltip: obscured
                                    ? l10n.revealPassword
                                    : l10n.hidePassword,
                                onPressed: () =>
                                    setState(() => obscured = !obscured),
                                icon: Icon(
                                  obscured
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FilledButton(
                            onPressed: busy
                                ? null
                                : () {
                                    if (password.text.isNotEmpty) {
                                      setState(() {
                                        busy = true;
                                        failed = false;
                                      });
                                      _open(password.text);
                                    }
                                  },
                            child: Text(l10n.unlockButton),
                          ),
                        ],
                        if (busy)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
