import 'package:authentication/app.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/settings/settings_provider.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets(
    'named routes return selected values and preserve the back stack',
    (tester) async {
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            navigatorKey: key,
            home: const Scaffold(body: Text('Home')),
            onGenerateRoute: onGenerateRoute,
          ),
        ),
      );
      final selection = key.currentState!.pushNamed<String>(AppRoutes.icons);
      await tester.pumpAndSettle();
      expect(key.currentState!.canPop(), isTrue);
      key.currentState!.pop('assets/icons/github.svg');
      await tester.pumpAndSettle();
      expect(await selection, 'assets/icons/github.svg');
      expect(find.text('Home'), findsOneWidget);
    },
  );
  testWidgets('manual save ends the add flow', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorKey: key,
          home: const Scaffold(body: Text('Home')),
          onGenerateRoute: onGenerateRoute,
        ),
      ),
    );
    key.currentState!.pushNamed(AppRoutes.add);
    await tester.pumpAndSettle();
    key.currentState!.pushNamed(AppRoutes.form);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Issuer'), 'Example');
    await tester.enterText(find.widgetWithText(TextField, 'Account'), 'user');
    await tester.enterText(
      find.widgetWithText(TextField, 'Secret'),
      'JBSWY3DPEHPK3PXP',
    );
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
    expect(key.currentState!.canPop(), isFalse);
    expect((await db.getAllConfigs()).single.account, 'user');
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });

  testWidgets('unknown route is sanitized and returns to origin', (
    tester,
  ) async {
    final key = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorKey: key,
          home: const Scaffold(body: Text('Home')),
          onGenerateRoute: onGenerateRoute,
        ),
      ),
    );
    key.currentState!.pushNamed('/unknown-sensitive-value');
    await tester.pumpAndSettle();
    expect(find.textContaining('unknown-sensitive-value'), findsNothing);
    final context = tester.element(find.text('This page is unavailable.'));
    expect(ModalRoute.of(context)!.settings.name, '/unavailable');
    key.currentState!.pop();
    await tester.pumpAndSettle();
    expect(find.text('Home'), findsOneWidget);
  });
  testWidgets('account card and actions fit on a narrow scaled screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await db.addConfig(
      const OtpAccount(
        type: 'totp',
        issuer: 'Example',
        account: 'user',
        secret: 'JBSWY3DPEHPK3PXP',
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          externalLinksProvider.overrideWithValue(const Stream.empty()),
          screenProtectionApplyProvider.overrideWithValue((_) async {}),
        ],
        child: const AuthApp(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byTooltip('Account actions'),
      100,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.byTooltip('Account actions'), findsOneWidget);
    await tester.tap(find.byTooltip('Account actions'));
    await tester.pumpAndSettle();
    expect(find.text('Edit'), findsOneWidget);
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(TextField, 'Issuer'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
