import 'dart:async';

import 'package:authentication/app.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('failed completion keeps introduction visible and allows retry', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    var attempts = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(database),
          introductionPreferencesProvider.overrideWithValue(preferences),
          completeIntroductionProvider.overrideWithValue(() async {
            attempts++;
            return attempts > 1;
          }),
          externalLinksProvider.overrideWithValue(const Stream.empty()),
        ],
        child: const AuthApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Get started'), 200);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Save Failed'), findsOneWidget);
    expect(find.text('Welcome'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsNothing);
    expect(attempts, 2);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });

  testWidgets('first launch persists completion and accepts external links', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    database.encryption = await EncryptionService.initialize(database);
    final links = StreamController<String>.broadcast();
    addTearDown(links.close);
    Widget app() => ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        introductionPreferencesProvider.overrideWithValue(preferences),
        externalLinksProvider.overrideWithValue(links.stream),
      ],
      child: const AuthApp(),
    );
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsOneWidget);
    links.add(
      'otpauth://totp/Example:user?secret=JBSWY3DPEHPK3PXP&issuer=Example',
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Issuer'), findsOneWidget);
    Navigator.of(tester.element(find.widgetWithText(TextField, 'Issuer')))
        .pop();
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Get started'), 200);
    await tester.tap(find.text('Get started'));
    await tester.pumpAndSettle();
    expect(preferences.getBool(introductionSeenKey), isTrue);
    expect(find.text('Welcome'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
