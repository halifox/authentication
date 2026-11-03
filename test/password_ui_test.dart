import 'dart:io';

import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/main.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/screens/settings_screen.dart';
import 'package:authentication/settings/settings.dart';
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
  testWidgets(
    'auto lock hides accounts and requires the password after timeout',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      SharedPreferences.setMockInitialValues({'introduction_seen': true});
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final folder = (await tester.runAsync(
        () => Directory.systemTemp.createTemp('auth-lock-test-'),
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
        await setup.setIntegerSetting(autoLockKey, 60);
        await setup.setSetting(screenProtectionKey, false);
        await setup.encryption.changePassword(newPassword: 'first-password');
        await setup.close();
      });
      var now = DateTime(2026);
      final protection = <bool>[];
      var failProtection = false;
      final reopened = AppDatabase(NativeDatabase(path));
      await tester.pumpWidget(
        AppBootstrap(
          database: reopened,
          applyScreenProtection: (enabled) async {
            protection.add(enabled);
            if (enabled && failProtection) throw StateError('Unavailable');
          },
          now: () => now,
        ),
      );
      await waitFor(
        tester,
        () => find.widgetWithText(FilledButton, 'Unlock').evaluate().isNotEmpty,
      );
      await tester.enterText(find.byType(TextField), 'first-password');
      await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
      await tester.pump();
      await waitFor(tester, () => find.text('alice').evaluate().isNotEmpty);
      await tester.tap(find.widgetWithText(TextField, 'Search'));
      await tester.pump();
      final searchFocus = FocusManager.instance.primaryFocus!;
      expect(searchFocus.hasFocus, true);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      expect(find.text('alice'), findsNothing);
      expect(searchFocus.hasFocus, false);
      now = now.add(const Duration(seconds: 30));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await waitFor(tester, () => find.text('alice').evaluate().isNotEmpty);
      expect(protection.last, false);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      now = now.add(const Duration(seconds: 60));
      failProtection = true;
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await waitFor(
        tester,
        () => find
            .textContaining('Unable to open the app securely')
            .evaluate()
            .isNotEmpty,
      );
      expect(find.text('alice'), findsNothing);
      failProtection = false;
      await tester.tap(find.text('Try again'));
      await tester.pump();
      await waitFor(
        tester,
        () => find.widgetWithText(FilledButton, 'Unlock').evaluate().isNotEmpty,
      );
      expect(protection.last, true);
      expect(find.text('alice'), findsNothing);
      await tester.enterText(find.byType(TextField), 'wrong');
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
      expect(protection.last, false);
      await tester.runAsync(() => reopened.setIntegerSetting(autoLockKey, -1));
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await waitFor(
        tester,
        () => find.widgetWithText(FilledButton, 'Unlock').evaluate().isNotEmpty,
      );
      await tester.enterText(find.byType(TextField), 'first-password');
      await tester.tap(find.widgetWithText(FilledButton, 'Unlock'));
      await tester.pump();
      await waitFor(tester, () => find.text('alice').evaluate().isNotEmpty);
      await tester.runAsync(
        () => reopened.encryption.changePassword(
          currentPassword: 'first-password',
        ),
      );
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      await tester.pump();
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();
      await waitFor(tester, () => find.text('alice').evaluate().isNotEmpty);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
      debugDefaultTargetPlatformOverride = null;
    },
  );
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
    await tester.tap(find.byKey(const ValueKey(autoLockKey)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Immediately').last);
    await tester.pumpAndSettle();
    expect((await db.getIntegerSettings())[autoLockKey], -1);
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
    await tester.ensureVisible(find.text('Change password'));
    await tester.pumpAndSettle();
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
    await tester.ensureVisible(find.text('Remove password'));
    await tester.pumpAndSettle();
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
