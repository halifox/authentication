import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/screens/migration_guide_screen.dart';
import 'package:authentication/screens/token_list_screen.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/settings/settings_provider.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:material_ui/material_ui.dart' as material_ui;
import 'package:shared_preferences/shared_preferences.dart';

const introductionSeenKey = 'introduction_seen';
final introductionPreferencesProvider = Provider<SharedPreferences?>(
  (ref) => null,
);

class AuthApp extends ConsumerStatefulWidget {
  const AuthApp({super.key});

  @override
  ConsumerState<AuthApp> createState() => _AuthAppState();
}

final externalLinksProvider = Provider<Stream<String>>((ref) {
  if (kIsWeb || defaultTargetPlatform != TargetPlatform.android)
    return const Stream.empty();
  return AppLinks().stringLinkStream;
});

class _AuthAppState extends ConsumerState<AuthApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription<String>? links;

  @override
  void initState() {
    super.initState();
    links = ref
        .read(externalLinksProvider)
        .listen(
          _handleLink,
          onError: (Object error, StackTrace stack) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final context = navigatorKey.currentContext;
              if (mounted && context != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      AppLocalizations.of(context)!.externalAccountUnavailable,
                    ),
                  ),
                );
              }
            });
            WidgetsBinding.instance.ensureVisualUpdate();
          },
        );
  }

  @override
  void dispose() {
    links?.cancel();
    super.dispose();
  }

  void _handleLink(String link) {
    if (!link.toLowerCase().startsWith('otpauth:')) return;
    final route = externalAccountRoute(link);
    final navigator = navigatorKey.currentState;
    if (navigator != null) {
      navigator.push(route);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) navigatorKey.currentState?.push(route);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    const pageTransitionsTheme = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.fuchsia: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
        TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
      },
    );
    final settings = ref.watch(settingsProvider).value;
    final integers = ref.watch(integerSettingsProvider).value;
    final mode = integers?[themeModeKey] ?? 0;
    final accent = integers?[accentColorKey] ?? 0;
    final language = integers?[languageKey] ?? 0;
    final dynamicEnabled = settings?[dynamicColorKey] ?? true;
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Authentication',
        debugShowCheckedModeBanner: false,
        themeMode: switch (mode) {
          1 => ThemeMode.light,
          2 || 3 => ThemeMode.dark,
          _ => ThemeMode.system,
        },
        theme: ThemeData(
          colorScheme: appColorScheme(
            Brightness.light,
            dynamicEnabled ? toFlutterColorScheme(lightDynamic) : null,
            accent,
            false,
          ),
          pageTransitionsTheme: pageTransitionsTheme,
        ),
        darkTheme: ThemeData(
          colorScheme: appColorScheme(
            Brightness.dark,
            dynamicEnabled ? toFlutterColorScheme(darkDynamic) : null,
            accent,
            mode == 3 || mode == 4,
          ),
          pageTransitionsTheme: pageTransitionsTheme,
        ),
        locale: language == 0 ? null : Locale(languageCodes[language - 1]),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        localeResolutionCallback: (locale, supportedLocales) {
          // 如果当前系统语言在支持的语言列表中，直接返回
          if (locale != null) {
            for (final supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
          }
          // 如果不支持当前语言，回退到英文
          return const Locale('en');
        },
        onGenerateRoute: (settings) => settings.name == AppRoutes.home
            ? MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => const _InitialScreen(),
              )
            : onGenerateRoute(settings),
      ),
    );
  }
}

class _InitialScreen extends ConsumerStatefulWidget {
  const _InitialScreen();

  @override
  ConsumerState<_InitialScreen> createState() => _InitialScreenState();
}

class _InitialScreenState extends ConsumerState<_InitialScreen> {
  bool? seen;
  bool saving = false;

  @override
  Widget build(BuildContext context) {
    final preferences = ref.watch(introductionPreferencesProvider);
    seen ??= preferences?.getBool(introductionSeenKey) ?? (preferences == null);
    if (seen!) return const TokenListScreen();
    return IntroductionScreen(
      saving: saving,
      onContinue: () async {
        setState(() => saving = true);
        var saved = false;
        try {
          saved = await preferences!.setBool(introductionSeenKey, true);
        } catch (_) {
          // Keep the introduction visible when the completion marker fails.
        }
        if (!context.mounted) return;
        setState(() {
          saving = false;
          seen = saved;
        });
        if (!saved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.saveFailed)),
          );
        }
      },
    );
  }
}

ColorScheme appColorScheme(
  Brightness brightness,
  ColorScheme? dynamicScheme,
  int accent,
  bool black,
) {
  const seeds = <int, Color>{
    1: Colors.red,
    2: Colors.orange,
    3: Colors.green,
    4: Colors.teal,
    5: Colors.blue,
    6: Colors.indigo,
    7: Colors.pink,
  };
  final seed = seeds[accent];
  var scheme =
      dynamicScheme ??
      (seed == null
          ? ThemeData(brightness: brightness).colorScheme
          : ColorScheme.fromSeed(seedColor: seed, brightness: brightness));
  if (black && brightness == Brightness.dark) {
    scheme = scheme.copyWith(
      surface: Colors.black,
      surfaceDim: Colors.black,
      surfaceBright: Colors.black,
      surfaceContainerLowest: Colors.black,
      surfaceContainerLow: Colors.black,
      surfaceContainer: Colors.black,
      surfaceContainerHigh: Colors.black,
      surfaceContainerHighest: Colors.black,
    );
  }
  return scheme;
}

ColorScheme? toFlutterColorScheme(material_ui.ColorScheme? scheme) {
  if (scheme == null) return null;
  return ColorScheme(
    brightness: scheme.brightness,
    primary: scheme.primary,
    onPrimary: scheme.onPrimary,
    primaryContainer: scheme.primaryContainer,
    onPrimaryContainer: scheme.onPrimaryContainer,
    secondary: scheme.secondary,
    onSecondary: scheme.onSecondary,
    secondaryContainer: scheme.secondaryContainer,
    onSecondaryContainer: scheme.onSecondaryContainer,
    tertiary: scheme.tertiary,
    onTertiary: scheme.onTertiary,
    tertiaryContainer: scheme.tertiaryContainer,
    onTertiaryContainer: scheme.onTertiaryContainer,
    error: scheme.error,
    onError: scheme.onError,
    errorContainer: scheme.errorContainer,
    onErrorContainer: scheme.onErrorContainer,
    surface: scheme.surface,
    onSurface: scheme.onSurface,
    surfaceDim: scheme.surfaceDim,
    surfaceBright: scheme.surfaceBright,
    surfaceContainerLowest: scheme.surfaceContainerLowest,
    surfaceContainerLow: scheme.surfaceContainerLow,
    surfaceContainer: scheme.surfaceContainer,
    surfaceContainerHigh: scheme.surfaceContainerHigh,
    surfaceContainerHighest: scheme.surfaceContainerHighest,
    onSurfaceVariant: scheme.onSurfaceVariant,
    outline: scheme.outline,
    outlineVariant: scheme.outlineVariant,
    shadow: scheme.shadow,
    scrim: scheme.scrim,
    inverseSurface: scheme.inverseSurface,
    onInverseSurface: scheme.onInverseSurface,
    inversePrimary: scheme.inversePrimary,
    surfaceTint: scheme.surfaceTint,
    primaryFixed: scheme.primaryFixed,
    primaryFixedDim: scheme.primaryFixedDim,
    onPrimaryFixed: scheme.onPrimaryFixed,
    onPrimaryFixedVariant: scheme.onPrimaryFixedVariant,
    secondaryFixed: scheme.secondaryFixed,
    secondaryFixedDim: scheme.secondaryFixedDim,
    onSecondaryFixed: scheme.onSecondaryFixed,
    onSecondaryFixedVariant: scheme.onSecondaryFixedVariant,
    tertiaryFixed: scheme.tertiaryFixed,
    tertiaryFixedDim: scheme.tertiaryFixedDim,
    onTertiaryFixed: scheme.onTertiaryFixed,
    onTertiaryFixedVariant: scheme.onTertiaryFixedVariant,
  );
}
