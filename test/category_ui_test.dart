import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/screens/categories_screen.dart';
import 'package:authentication/screens/token_form_screen.dart';
import 'package:authentication/screens/token_list_screen.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

Widget app(AppDatabase db, Widget child) => ProviderScope(
  overrides: [appDatabaseProvider.overrideWithValue(db)],
  child: MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const alice = OtpAccount(
    type: 'hotp',
    issuer: 'Example',
    account: 'alice',
    secret: 'JBSWY3DPEHPK3PXP',
  );
  const bob = OtpAccount(
    type: 'hotp',
    issuer: 'Example',
    account: 'bob',
    secret: 'JBSWY3DPEHPK3PXP',
  );
  testWidgets('manage categories and assign accounts in bulk', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await db.addConfig(alice);
    await db.addConfig(bob);
    await tester.pumpWidget(app(db, const CategoriesScreen()));
    await tester.pumpAndSettle();
    expect(find.text('No categories yet.'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Work');
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Work'), findsOneWidget);
    await tester.tap(find.byTooltip('Category actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Set as default'));
    await tester.pumpAndSettle();
    expect(find.text('Default'), findsOneWidget);
    await tester.tap(find.byTooltip('Category actions'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Assign accounts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Example · alice'));
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    final category = (await db.getCategories()).single;
    final accounts = await db.getAllConfigs();
    expect((await db.getCategoryMemberships())[accounts.first.id], {
      category.id,
    });
    expect((await db.getCategoryMemberships())[accounts.last.id], isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
  testWidgets(
    'account selection and list filters reflect category membership',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      await db.createCategory('Work');
      await db.createCategory('Home');
      await db.addConfig(alice);
      await db.addConfig(bob);
      final accounts = await db.getAllConfigs();
      await tester.pumpWidget(
        app(db, TokenFormScreen(initialEntry: accounts.first)),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Assign categories'));
      await tester.tap(find.text('Assign categories'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Work').last);
      await tester.tap(find.text('Home').last);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect((await db.getCategoryMemberships())[accounts.first.id]!.length, 2);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
      await tester.pumpWidget(app(db, const TokenListScreen()));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Filter categories'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Work').last);
      await tester.pumpAndSettle();
      expect(find.text('alice'), findsOneWidget);
      expect(find.text('bob'), findsNothing);
      await tester.tap(find.byTooltip('Filter categories'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Uncategorized').last);
      await tester.pumpAndSettle();
      expect(find.text('alice'), findsNothing);
      expect(find.text('bob'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    },
  );
}
