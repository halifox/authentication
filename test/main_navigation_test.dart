import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/screens/main_navigation_screen.dart';
import 'package:authentication/screens/settings_screen.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

void main() {
  testWidgets(
    'tabs preserve account search and secondary routes cover the bar',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      await db.addConfig(
        const OtpAccount(
          type: 'hotp',
          issuer: 'Example',
          account: 'Alice',
          secret: 'JBSWY3DPEHPK3PXP',
        ),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            onGenerateRoute: onGenerateRoute,
            home: MainNavigationScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Example');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.backup_outlined));
      await tester.pumpAndSettle();
      expect(find.text('Restore app backup'), findsOneWidget);
      await tester.tap(find.text('Import other formats'));
      await tester.pumpAndSettle();
      expect(find.byType(GlassTabBar), findsNothing);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(GlassTabBar), findsOneWidget);
      await tester.tap(find.byIcon(Icons.settings).first);
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
      await tester.tap(find.byIcon(Icons.shield_outlined));
      await tester.pumpAndSettle();
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Example',
      );
      expect(find.text('Alice'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    },
  );

  testWidgets('bottom navigation fits a narrow viewport with large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          locale: Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: onGenerateRoute,
          home: MainNavigationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.settings).first);
    await tester.pumpAndSettle();
    expect(find.byType(GlassTabBar), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
