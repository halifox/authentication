import 'dart:async';

import 'package:authentication/app.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/settings/settings_provider.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('Android plugin event is delivered to the account form', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    const channel = MethodChannel('com.llfbandit.app_links/events');
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      channel,
      (call) async => null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        null,
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          screenProtectionApplyProvider.overrideWithValue((_) async {}),
        ],
        child: const AuthApp(),
      ),
    );
    await tester.pumpAndSettle();
    const uri =
        'otpauth://hotp/Example:user?secret=JBSWY3DPEHPK3PXP&issuer=Example&counter=1';
    final data = const StandardMethodCodec().encodeSuccessEnvelope(uri);
    await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
      'com.llfbandit.app_links/events',
      data,
      (_) {},
    );
    await tester.pumpAndSettle();
    final field = find.widgetWithText(TextField, 'Issuer');
    expect(field, findsOneWidget);
    expect(
      ModalRoute.of(tester.element(field))!.settings.name,
      '/external-account',
    );
    expect(await db.getAllConfigs(), isEmpty);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    debugDefaultTargetPlatformOverride = null;
  });
  testWidgets('incoming links require review and never become route names', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    final links = StreamController<String>();
    addTearDown(links.close);
    const uri =
        'otpauth://totp/Example:user?secret=JBSWY3DPEHPK3PXP&issuer=Example';
    links.add(uri);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          externalLinksProvider.overrideWithValue(links.stream),
          screenProtectionApplyProvider.overrideWithValue((_) async {}),
        ],
        child: const AuthApp(),
      ),
    );
    await tester.pumpAndSettle();
    var field = find.widgetWithText(TextField, 'Issuer');
    expect(field, findsOneWidget);
    expect(
      ModalRoute.of(tester.element(field))!.settings.name,
      '/external-account',
    );
    expect(await db.getAllConfigs(), isEmpty);
    Navigator.of(tester.element(field)).pop();
    await tester.pumpAndSettle();
    expect(await db.getAllConfigs(), isEmpty);
    links.addError(StateError('sensitive plugin detail'));
    await tester.idle();
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text('Could not receive external account links.'),
      findsOneWidget,
    );
    expect(find.textContaining('sensitive plugin detail'), findsNothing);
    links.add(uri);
    await tester.pumpAndSettle();
    field = find.widgetWithText(TextField, 'Issuer');
    expect(
      ModalRoute.of(tester.element(field))!.settings.name,
      '/external-account',
    );
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    expect((await db.getAllConfigs()).single.account, 'user');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
  testWidgets('Yandex link requires a PIN before saving', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                externalAccountRoute(
                  'otpauth://yaotp/person?secret=LA2V6KMCGYMWWVEW64RNP3JA3IAAAAAAHTSG4HRZPI&pin_length=4',
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(await db.getAllConfigs(), isEmpty);
    final pin = find.widgetWithText(TextField, 'PIN must contain 4 characters');
    expect(pin, findsOneWidget);
    expect(tester.widget<TextField>(pin).obscureText, isTrue);
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    expect(await db.getAllConfigs(), isEmpty);
    await tester.tap(find.text('OK').last);
    await tester.pumpAndSettle();
    await tester.enterText(pin, '7586');
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    final account = (await db.getAllConfigs()).single;
    expect(account.type, 'yandex');
    expect(account.pin, '7586');
    expect(account.generateCodeString().length, 8);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });

  testWidgets('invalid external link shows a safe error', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                externalAccountRoute('otpauth://totp/bad?secret=INVALID!'),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(
      find.text('The link is invalid or unsupported. No account was imported.'),
      findsOneWidget,
    );
    expect(await db.getAllConfigs(), isEmpty);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
