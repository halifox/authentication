import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/screens/account_search_screen.dart';
import 'package:authentication/screens/main_navigation_screen.dart';
import 'package:authentication/screens/settings_screen.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

Future<void> openSearch(WidgetTester tester) async {
  await tester.tap(find.byIcon(CupertinoIcons.search).hitTestable().first);
  await tester.pumpAndSettle();
  await tester.tap(find.byType(CupertinoTextField).hitTestable().first);
  await tester.pumpAndSettle();
}

Future<AppDatabase> pumpApp(
  WidgetTester tester, {
  Locale locale = const Locale('en'),
}) async {
  FlutterSecureStorage.setMockInitialValues({});
  final db = AppDatabase(NativeDatabase.memory());
  db.encryption = await EncryptionService.initialize(db);
  await db.addConfig(
    const OtpAccount(
      type: 'hotp',
      issuer: 'Example',
      account: 'Alice',
      secret: 'JBSWY3DPEHPK3PXP',
    ),
  );
  await db.addConfig(
    const OtpAccount(
      type: 'hotp',
      issuer: 'Other',
      account: 'Bob',
      secret: 'JBSWY3DPEHPK3PXP',
    ),
  );
  await tester.pumpWidget(
    ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        onGenerateRoute: onGenerateRoute,
        home: const MainNavigationScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return db;
}

Future<List<String>> savedQueries(WidgetTester tester, AppDatabase db) async =>
    (await tester.runAsync(() => db.watchRecentSearches().first))!;

void main() {
  testWidgets(
    'bottom search submits, remembers, repeats and deletes a local query',
    (tester) async {
      final db = await pumpApp(tester);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        await db.close();
      });
      await tester.tap(find.byIcon(Icons.settings).hitTestable().first);
      await tester.pumpAndSettle();
      await openSearch(tester);
      expect(find.byType(AccountSearchScreen), findsOneWidget);
      expect(find.text('No recent searches'), findsOneWidget);
      await tester.enterText(
        find.byType(CupertinoTextField).hitTestable().first,
        '  EXAMPLE  ',
      );
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsNothing);
      expect(find.byType(GlassTabBar), findsNothing);
      expect(await savedQueries(tester, db), ['EXAMPLE']);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.text('EXAMPLE'));
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsOneWidget);
      expect(await savedQueries(tester, db), ['EXAMPLE']);
      await tester.pageBack();
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Delete'));
      await tester.pumpAndSettle();
      expect(find.text('No recent searches'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    },
  );

  testWidgets(
    'history clear can be cancelled and category browse does not record empty searches',
    (tester) async {
      final db = await pumpApp(tester);
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        await db.close();
      });
      await db.rememberSearch('Example');
      await db.rememberSearch('Other');
      await openSearch(tester);
      await tester.tap(find.byTooltip('Clear history'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel').last);
      await tester.pumpAndSettle();
      expect((await savedQueries(tester, db)).length, 2);
      await tester.tap(find.byTooltip('Clear history'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Clear history').last);
      await tester.pumpAndSettle();
      expect(await savedQueries(tester, db), isEmpty);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(CupertinoIcons.search).hitTestable().first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('All accounts').last);
      await tester.pumpAndSettle();
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(await savedQueries(tester, db), isEmpty);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    },
  );

  testWidgets(
    'native search stays above the keyboard on a narrow scaled screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetViewInsets);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final db = await pumpApp(tester, locale: const Locale('zh'));
      addTearDown(() async {
        await tester.pumpWidget(const SizedBox());
        await db.close();
      });
      await openSearch(tester);
      tester.view.viewInsets = const FakeViewPadding(bottom: 250);
      await tester.pumpAndSettle();
      expect(
        tester.getBottomLeft(find.byType(GlassTabBar)).dy,
        lessThanOrEqualTo(390),
      );
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    },
  );
}
