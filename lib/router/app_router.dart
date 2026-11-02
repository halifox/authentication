import 'package:authentication/otp/account.dart';
import 'package:authentication/screens/add_account_screen.dart';
import 'package:authentication/screens/categories_screen.dart';
import 'package:authentication/screens/icon_selection_screen.dart';
import 'package:authentication/screens/qr_scanner_screen.dart';
import 'package:authentication/screens/settings_screen.dart';
import 'package:authentication/screens/token_form_screen.dart';
import 'package:authentication/screens/token_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class AppRoutes {
  static const home = '/';
  static const add = '/add';
  static const settings = '/settings';
  static const categories = '/categories';
  static const form = '/form';
  static const scan = '/scan';
  static const icons = '/icons';
}

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  final Widget screen = switch (settings.name) {
    AppRoutes.add => const AddAccountScreen(),
    AppRoutes.settings => const SettingsScreen(),
    AppRoutes.categories => const CategoriesScreen(),
    AppRoutes.form => TokenFormScreen(
      initialEntry: settings.arguments as OtpAccount?,
    ),
    AppRoutes.scan => const QrScannerScreen(),
    AppRoutes.icons => const IconSelectionScreen(),
    _ => const TokenListScreen(),
  };
  if (settings.name == AppRoutes.icons) {
    return MaterialPageRoute<String>(
      settings: settings,
      builder: (_) => screen,
    );
  }
  if (settings.name == AppRoutes.scan) {
    return MaterialPageRoute<BarcodeCapture>(
      settings: settings,
      builder: (_) => screen,
    );
  }
  return MaterialPageRoute<void>(settings: settings, builder: (_) => screen);
}
