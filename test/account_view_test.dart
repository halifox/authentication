import 'package:authentication/backup/backup.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/screens/settings_screen.dart';
import 'package:authentication/screens/token_list_screen.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:authentication/widgets/token_list_item.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('view setting changes card layout and survives backup', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1000, 900);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await db.addConfig(
      const OtpAccount(
        type: 'hotp',
        issuer: 'Example',
        account: 'one',
        secret: 'JBSWY3DPEHPK3PXP',
      ),
    );
    await db.addConfig(
      const OtpAccount(
        type: 'hotp',
        issuer: 'Example',
        account: 'two',
        secret: 'JBSWY3DPEHPK3PXP',
      ),
    );
    Widget app(Widget home, {double scale = 1}) => ProviderScope(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: home,
      ),
    );
    await tester.pumpWidget(app(const TokenListScreen()));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(TokenListItem).first).height, 140);
    await db.setIntegerSetting(accountViewKey, 1);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(TokenListItem).first).height, 120);
    await db.setIntegerSetting(accountViewKey, 2);
    await tester.pumpAndSettle();
    final cards = find.byType(TokenListItem);
    expect(
      tester.getTopLeft(cards.at(0)).dy,
      tester.getTopLeft(cards.at(1)).dy,
    );
    expect(
      tester.getTopLeft(cards.at(0)).dx,
      lessThan(tester.getTopLeft(cards.at(1)).dx),
    );
    await db.setSetting(sortLockedKey, false);
    await tester.pumpAndSettle();
    expect(find.byType(ReorderableListView), findsOneWidget);
    await db.setSetting(sortLockedKey, true);
    await tester.pumpAndSettle();
    final backup = await encodeBackupAccounts(
      await db.getAllConfigs(),
      null,
      settings: await db.getSettings(),
      integerSettings: await db.getIntegerSettings(),
    );
    expect(
      (await decodeBackupDocument(
        backup,
        null,
      )).integerSettings![accountViewKey],
      2,
    );
    tester.view.physicalSize = const Size(320, 800);
    await tester.pumpWidget(app(const TokenListScreen(), scale: 1.6));
    await tester.pumpAndSettle();
    expect(find.byType(TokenListItem), findsWidgets);
    tester.view.physicalSize = const Size(1000, 900);
    await tester.pumpWidget(app(const SettingsScreen()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey(accountViewKey)),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.byKey(const ValueKey(accountViewKey)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compact').last);
    await tester.pumpAndSettle();
    expect((await db.getIntegerSettings())[accountViewKey], 1);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
