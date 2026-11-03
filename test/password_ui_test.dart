import 'dart:io';

import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/main.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/screens/settings_screen.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> waitFor(WidgetTester tester, bool Function() condition) async {
  for (var i = 0; i < 250 && !condition(); i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 40)),
    );
    await tester.pump();
  }
  expect(condition(), isTrue);
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('settings creates, changes and removes password', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PasswordScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'New password'),
      'first-password',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm new password'),
      'first-password',
    );
    await tester.pump();
    await tester.tap(find.text('Set password'));
    await tester.pump();
    await waitFor(
      tester,
      () => find.text('Change password').evaluate().isNotEmpty,
    );
    expect(await db.encryption.passwordEnabled, true);
    await tester.enterText(
      find.widgetWithText(TextField, 'Current password'),
      'first-password',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'New password'),
      'second-password',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirm new password'),
      'second-password',
    );
    await tester.pump();
    await tester.tap(find.text('Change password'));
    await tester.pump();
    await waitFor(
      tester,
      () =>
          find
              .widgetWithText(TextField, 'New password')
              .evaluate()
              .isNotEmpty &&
          tester
              .widget<TextField>(find.widgetWithText(TextField, 'New password'))
              .controller!
              .text
              .isEmpty,
    );
    ScaffoldMessenger.of(tester.element(find.byType(PasswordScreen)))
        .clearSnackBars();
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Current password'),
      'second-password',
    );
    await tester.pump();
    await tester.tap(find.text('Remove password'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove password').last);
    await tester.pump();
    await waitFor(
      tester,
      () => find.text('Set password').evaluate().isNotEmpty,
    );
    expect(await db.encryption.passwordEnabled, false);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });

  testWidgets('startup requires correct password before opening accounts', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    SharedPreferences.setMockInitialValues({'introduction_seen': true});
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final folder = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('auth-password-test-'),
    ))!;
    addTearDown(() => folder.delete(recursive: true));
    final path = File('${folder.path}/db.sqlite');
    await tester.runAsync(() async {
      final setup = AppDatabase(NativeDatabase(path));
      setup.encryption = await EncryptionService.initialize(setup);
      await setup.addConfig(
        const OtpAccount(
          type: 'totp',
          issuer: 'Example',
          account: 'alice',
          secret: 'JBSWY3DPEHPK3PXP',
        ),
      );
      await setup.encryption.changePassword(newPassword: 'first-password');
      await setup.close();
    });
    final reopened = AppDatabase(NativeDatabase(path));
    await tester.pumpWidget(
      AppBootstrap(database: reopened, protectScreen: () async {}),
    );
    await waitFor(tester, () => find.text('Unlock').evaluate().length >= 2);
    expect(find.text('alice'), findsNothing);
    await tester.enterText(find.byType(TextField), 'wrong-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
    await tester.pump();
    await waitFor(
      tester,
      () => find.textContaining('Unable to unlock').evaluate().isNotEmpty,
    );
    expect(find.text('alice'), findsNothing);
    await tester.enterText(find.byType(TextField), 'first-password');
    await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
    await tester.pump();
    await waitFor(tester, () => find.text('alice').evaluate().isNotEmpty);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    debugDefaultTargetPlatformOverride = null;
  });
}
