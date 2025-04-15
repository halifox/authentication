import 'package:auth/auth.dart';
import 'package:auth/otp.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_swipe_action_cell/core/swipe_action_navigator_observer.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:auth/ui/add_screen.dart';
import 'package:auth/ui/from_screen.dart';
import 'package:auth/ui/home_screen.dart';
import 'package:auth/auth_repository.dart';
import 'package:auth/ui/scan_screen.dart';
import 'package:auth/ui/settings_screen.dart';
import 'package:sembast/sembast.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();

  await initDatabase();
  await initSharedPreferences();

  await settingsStore.record('biometricUnlock').put(db, false);
  await settingsStore.record('isShowCaptchaOnTap').put(db, false);
  await settingsStore.record('isCopyCaptchaOnTap').put(db, false);

  if (kDebugMode) {
    await authStore.delete(db);
    await authStore.add(db, AuthenticationConfig(secret: OTP.randomSecret(), type: Type.totp, account: "user@github.com", issuer: "GitHub", intervalSeconds: 30).toJson());
    await authStore.add(db, AuthenticationConfig(secret: OTP.randomSecret(), type: Type.totp, account: "user@gmail.com", issuer: "Google", intervalSeconds: 30).toJson());
    await authStore.add(db, AuthenticationConfig(secret: OTP.randomSecret(), type: Type.totp, account: "user@icloud.com", issuer: "Apple", intervalSeconds: 40).toJson());
    await authStore.add(db, AuthenticationConfig(secret: OTP.randomSecret(), type: Type.totp, account: "user@dropbox.com", issuer: "Dropbox", intervalSeconds: 45).toJson());
    await authStore.add(db, AuthenticationConfig(secret: OTP.randomSecret(), type: Type.totp, account: "user@1dot1dot1dot1.com", issuer: "1dot1dot1dot1", intervalSeconds: 60).toJson());
    await authStore.add(db, AuthenticationConfig(secret: OTP.randomSecret(), type: Type.hotp, account: "user@aws.com", issuer: "Amazon", counter: 0).toJson());
    await authStore.add(db, AuthenticationConfig(secret: OTP.randomSecret(), type: Type.hotp, account: "user@ansible.com", issuer: "ansible", counter: 0).toJson());
  }

  if (kDebugMode) {
    sp.clear();
    sp.getKeys().forEach((key) {
      final value = sp.get(key);
      print('$key:$value::${value.runtimeType}');
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: 'Purity Auth',
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: ThemeData(brightness: Brightness.light, colorScheme: lightDynamic),
          darkTheme: ThemeData(brightness: Brightness.dark, colorScheme: darkDynamic),
          initialRoute: '/',
          routes: <String, WidgetBuilder>{
            '/': (BuildContext context) => const HomeScreen(),
            '/AuthAddPage': (BuildContext context) => const AddScreen(),
            '/AuthScanPage': (BuildContext context) => const ScanScreen(),
            '/AuthFromPage': (BuildContext context) => const FromScreen(),
            '/AuthSettingsPage': (BuildContext context) => const SettingsScreen(),
          },
          navigatorObservers: <NavigatorObserver>[SwipeActionNavigatorObserver()],
        );
      },
    );
  }
}
