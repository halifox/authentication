import 'package:authentication/app.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/settings/settings.dart';
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
    super.key,
  });
  final AppDatabase? database;
  final FlutterSecureStorage? storage;
  final Future<void> Function()? protectScreen;

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
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

  @override
  void initState() {
    super.initState();
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
        if (widget.protectScreen != null) {
          await widget.protectScreen!();
        } else if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          await ScreenSecurity().enable();
        }
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
    password.dispose();
    if (!handedOff) db.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prefs = preferences;
    if (prefs != null) {
      handedOff = true;
      return ProviderScope(
        overrides: [
          introductionPreferencesProvider.overrideWithValue(prefs),
          appDatabaseProvider.overrideWith((ref) {
            ref.onDispose(db.close);
            return db;
          }),
        ],
        child: const AuthApp(),
      );
    }
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
                              _start();
                            },
                            child: Text(l10n.screenProtectionRetry),
                          ),
                        ] else if (locked) ...[
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
