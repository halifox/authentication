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
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          title: 'Purity Auth',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: ThemeData(brightness: Brightness.light, colorScheme: lightDynamic),
          darkTheme: ThemeData(brightness: Brightness.dark, colorScheme: darkDynamic),
          initialRoute: '/',
          routes: {
            '/': (context) => HomeScreen(),
            '/add': (context) => AddScreen(),
            '/scan': (context) => ScanScreen(),
            '/from': (context) => FromScreen(),
            '/settings': (context) => SettingsScreen(),
          },
          navigatorObservers: [SwipeActionNavigatorObserver()],
        );
      },
    );
  }
}
