import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/screens/add_account_screen.dart';
import 'package:authentication/screens/categories_screen.dart';
import 'package:authentication/screens/icon_selection_screen.dart';
import 'package:authentication/screens/migration_guide_screen.dart';
import 'package:authentication/screens/qr_scanner_screen.dart';
import 'package:authentication/screens/settings_screen.dart';
import 'package:authentication/screens/token_form_screen.dart';
import 'package:authentication/screens/token_list_screen.dart';
import 'package:authentication/widgets/custom_app_bar.dart';
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
  static const migrationGuides = '/migration-guides';
  static const userGuide = '/user-guide';
  static const about = '/about';
  static const automaticBackup = '/automatic-backup';
  static const password = '/password';
}

Route<void> externalAccountRoute(String name) {
  OtpAccount? account;
  int? pinLength;
  try {
    if (name.length > 65536) throw const FormatException();
    if (Uri.parse(name).host.toLowerCase() == 'yaotp') {
      final parsed = parseYandexProvisioning(name);
      account = parsed.account;
      pinLength = parsed.pinLength;
    } else {
      account = parseOtpUri(name, detectSteam: true)..validate();
    }
  } catch (_) {
    // Never include an external URI or parsing exception in the UI or route.
  }
  final parsedAccount = account;
  return MaterialPageRoute<void>(
    settings: const RouteSettings(name: '/external-account'),
    builder: (context) => parsedAccount == null
        ? Scaffold(
            appBar: CustomAppBar(
              title: AppLocalizations.of(context)!.externalAccount,
            ),
            body: Center(
              child: Text(AppLocalizations.of(context)!.externalAccountInvalid),
            ),
          )
        : TokenFormScreen(
            initialEntry: parsedAccount,
            expectedPinLength: pinLength,
          ),
  );
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
    AppRoutes.migrationGuides => const MigrationGuideScreen(),
    AppRoutes.userGuide => const UserGuideScreen(),
    AppRoutes.about => const AboutScreen(),
    AppRoutes.automaticBackup => const AutomaticBackupScreen(),
    AppRoutes.password => const PasswordScreen(),
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
