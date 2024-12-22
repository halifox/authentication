import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/swipe_action_navigator_observer.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:get/get.dart';
import 'package:purity_auth/auth_from_page.dart';
import 'package:purity_auth/auth_add_page.dart';
import 'package:purity_auth/auth_repository.dart';
import 'package:purity_auth/auth_scan_page.dart';
import 'package:purity_auth/auth_home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return GetMaterialApp(
          title: 'Purity Auth',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: ThemeData(
            brightness: Brightness.light,
            colorScheme: lightDynamic,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorScheme: darkDynamic,
          ),
          initialRoute: "/",
          getPages: [
            GetPage(name: '/', page: () => AuthHomePage()),
            GetPage(name: '/AuthAddPage', page: () => AuthAddPage()),
            GetPage(name: '/AuthScanPage', page: () => AuthScanPage()),
            GetPage(name: '/AuthFromPage', page: () => AuthFromPage()),
          ],
          navigatorObservers: [
            SwipeActionNavigatorObserver(),
          ],
        );
      },
    );
  }
}
