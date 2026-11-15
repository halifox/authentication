import 'dart:async';

import 'package:authentication/app.dart';
import 'package:authentication/screens/token_list_screen.dart';
import 'package:authentication/settings/settings_provider.dart';
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
  testWidgets('fresh launch opens accounts and accepts external links', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    database.encryption = await EncryptionService.initialize(database);
    final links = StreamController<String>.broadcast();
    addTearDown(links.close);
    Widget app() => ProviderScope(
      overrides: [
        appDatabaseProvider.overrideWithValue(database),
        screenProtectionApplyProvider.overrideWithValue((_) async {}),
        externalLinksProvider.overrideWithValue(links.stream),
      ],
      child: const AuthApp(),
    );
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsNothing);
    expect(find.byType(TokenListScreen), findsOneWidget);
    links.add(
      'otpauth://totp/Example:user?secret=JBSWY3DPEHPK3PXP&issuer=Example',
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Issuer'), findsOneWidget);
    Navigator.of(tester.element(find.widgetWithText(TextField, 'Issuer')))
        .pop();
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
    await tester.pumpWidget(app());
    await tester.pumpAndSettle();
    expect(find.text('Welcome'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
