import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/actions/icon_selection_provider.dart';
import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/otp_provider.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/screens/token_form_screen.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('matches only unambiguous normalized issuer names', () {
    expect(
      matchBuiltInIcon('  Git-Hub ', ['github.svg']),
      'assets/icons/github.svg',
    );
    expect(matchBuiltInIcon('Other', ['github.svg']), isNull);
    expect(matchBuiltInIcon('GitHub™', ['github.svg']), isNull);
    expect(matchBuiltInIcon('GitHub', ['github.svg', 'git-hub.svg']), isNull);
  });
  test(
    'scan and URI import match icons while preserving existing choices',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          allIconsProvider.overrideWith(
            (ref) async => ['github.svg', 'google.svg'],
          ),
        ],
      );
      addTearDown(container.dispose);
      final operations = container.read(accountOperationsProvider.notifier);
      await operations.scan(
        'otpauth://totp/GitHub:one?secret=JBSWY3DPEHPK3PXP&issuer=GitHub',
      );
      await operations.scan(
        'otpauth://totp/Steam:player?secret=63BEDWCQZKTQWPESARIERL5DTTQFCJTK&issuer=Steam',
      );
      var accounts = await db.getAllConfigs();
      expect(accounts.singleWhere((a) => a.issuer == 'Steam').type, 'steam');
      expect(
        accounts.singleWhere((a) => a.issuer == 'GitHub').icon,
        'assets/icons/github.svg',
      );
      await db.updateConfig(
        accounts
            .singleWhere((a) => a.issuer == 'GitHub')
            .copyWith(icon: 'assets/icons/google.svg'),
      );
      await operations.scan(
        'otpauth://totp/GitHub:one?secret=JBSWY3DPEHPK3PXP&issuer=GitHub',
        forceUpdate: true,
      );
      final input = Uint8List.fromList(
        utf8.encode(
          'otpauth://totp/GitHub:one?secret=JBSWY3DPEHPK3PXP&issuer=GitHub\notpauth://totp/GitHub:two?secret=JBSWY3DPEHPK3PXP&issuer=GitHub',
        ),
      );
      await container
          .read(backupOperationsProvider.notifier)
          .importUriFile(input);
      accounts = await db.getAllConfigs();
      expect(
        accounts.singleWhere((account) => account.account == 'one').icon,
        'assets/icons/google.svg',
      );
      expect(
        accounts.singleWhere((account) => account.account == 'two').icon,
        'assets/icons/github.svg',
      );
      await operations.importMigration([
        const OtpAccount(
          type: 'totp',
          issuer: 'Google',
          account: 'three',
          secret: 'JBSWY3DPEHPK3PXP',
        ),
      ]);
      expect(
        (await db.getAllConfigs())
            .singleWhere((account) => account.account == 'three')
            .icon,
        'assets/icons/google.svg',
      );
    },
  );
  testWidgets('matching icon is saved for a new account', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          allIconsProvider.overrideWith((ref) async => ['github.svg']),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TokenFormScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final field in {
      'Issuer': 'GitHub',
      'Account': 'user',
      'Secret': 'JBSWY3DPEHPK3PXP',
    }.entries) {
      final finder = find.widgetWithText(TextField, field.key);
      await tester.ensureVisible(finder);
      await tester.enterText(finder, field.value);
      await tester.pumpAndSettle();
    }
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    expect((await db.getAllConfigs()).single.icon, 'assets/icons/github.svg');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
  testWidgets('new account uses matched icon and manual choice wins', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          allIconsProvider.overrideWith(
            (ref) async => ['github.svg', 'google.svg'],
          ),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const TokenFormScreen(),
          onGenerateRoute: (settings) => settings.name == AppRoutes.icons
              ? MaterialPageRoute<String>(
                  builder: (context) => Scaffold(
                    body: TextButton(
                      onPressed: () =>
                          Navigator.pop(context, 'assets/icons/google.svg'),
                      child: const Text('Choose Google'),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    Future<void> fill(String label, String value) async {
      final field = find.widgetWithText(TextField, label);
      await tester.ensureVisible(field);
      await tester.enterText(field, value);
      await tester.pumpAndSettle();
    }

    await fill('Issuer', 'GitHub');
    await fill('Account', 'user');
    await fill('Secret', 'JBSWY3DPEHPK3PXP');
    await tester.ensureVisible(find.widgetWithText(TextField, 'Issuer'));
    await tester.tap(
      find
          .descendant(
            of: find.widgetWithText(TextField, 'Issuer'),
            matching: find.byType(GestureDetector),
          )
          .last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose Google'));
    await tester.pumpAndSettle();
    await fill('Issuer', 'GitHub Services');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    expect((await db.getAllConfigs()).single.icon, 'assets/icons/google.svg');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
