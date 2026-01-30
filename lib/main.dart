import 'package:auth/l10n/generated/app_localizations.dart';
import 'package:auth/router/app_router.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  runApp(const ProviderScope(child: AuthApp()));
}

class AuthApp extends ConsumerWidget {
  const AuthApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    
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
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) => MaterialApp.router(
        title: 'Purity Auth',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.system,
        theme: ThemeData(
          brightness: Brightness.light,
          colorScheme: lightDynamic,
          pageTransitionsTheme: pageTransitionsTheme,
        ),
        darkTheme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: darkDynamic,
          pageTransitionsTheme: pageTransitionsTheme,
        ),
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
        routerConfig: router,
      ),
    );
  }
}
