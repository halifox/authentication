import 'package:auth/repository.dart';
import 'package:auth/ui/add_screen.dart';
import 'package:auth/ui/from_screen.dart';
import 'package:auth/ui/home_screen.dart';
import 'package:auth/ui/scan_screen.dart';
import 'package:auth/ui/settings_screen.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/swipe_action_navigator_observer.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  await initDatabase();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(context) {
    final pageTransitionsTheme = PageTransitionsTheme(
      builders: {
        TargetPlatform.android: CupertinoPageTransitionsBuilder(),
        TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
      },
    );
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
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
          initialRoute: '/',
          routes: {
            '/': (BuildContext context) => HomeScreen(),
            '/add': (BuildContext context) => AddScreen(),
            '/scan': (BuildContext context) => ScanScreen(),
            '/from': (BuildContext context) => FromScreen(),
            '/settings': (BuildContext context) => SettingsScreen(),
            '/icons': (BuildContext context) => IconsChooseScreen(),
          },
          navigatorObservers: [SwipeActionNavigatorObserver()],
        );
      },
    );
  }
}
