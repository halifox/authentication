import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/sorting.dart';
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
  const accounts = [
    OtpAccount(
      id: 1,
      type: 'hotp',
      issuer: 'Zulu',
      account: 'z',
      secret: 'JBSWY3DPEHPK3PXP',
      sortOrder: 2,
      copyCount: 1,
    ),
    OtpAccount(
      id: 2,
      type: 'hotp',
      issuer: 'Alpha',
      account: 'a',
      secret: 'JBSWY3DPEHPK3PXP',
      sortOrder: 0,
      copyCount: 5,
    ),
    OtpAccount(
      id: 3,
      type: 'hotp',
      issuer: 'Beta',
      account: 'b',
      secret: 'JBSWY3DPEHPK3PXP',
      sortOrder: 1,
      copyCount: 1,
    ),
  ];
  test('all sorting modes use stable custom-order tie breaks', () {
    List<int> ids(int mode) =>
        sortAccounts(accounts, mode).map((e) => e.id).toList();
    expect(ids(0), [2, 3, 1]);
    expect(ids(1), [2, 3, 1]);
    expect(ids(2), [1, 3, 2]);
    expect(ids(3), [3, 1, 2]);
    expect(ids(4), [2, 3, 1]);
    expect(accounts.first.id, 1);
  });

  test(
    'reordering and backup restore are atomic and preserve legacy options',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      await db.initializeSettings(defaultSettings);
      for (final account in accounts) {
        await db.addConfig(account);
      }
      var saved = await db.getAllConfigs();
      expect(sortAccounts(saved, 0).map((e) => e.id), [1, 2, 3]);
      await db.reorderAccounts([3, 1, 2]);
      saved = await db.getAllConfigs();
      expect(sortAccounts(saved, 0).map((e) => e.id), [3, 1, 2]);
      await expectLater(db.reorderAccounts([3, 1]), throwsStateError);
      expect(sortAccounts(await db.getAllConfigs(), 0).map((e) => e.id), [
        3,
        1,
        2,
      ]);
      await db.customStatement(
        "CREATE TRIGGER reject_reorder BEFORE UPDATE OF sort_order ON auth_entries WHEN NEW.id = 2 BEGIN SELECT RAISE(ABORT, 'failure'); END",
      );
      await expectLater(db.reorderAccounts([1, 2, 3]), throwsA(anything));
      expect(sortAccounts(await db.getAllConfigs(), 0).map((e) => e.id), [
        3,
        1,
        2,
      ]);
      await db.customStatement('DROP TRIGGER reject_reorder');
      await db.updateConfig(saved.first.copyWith(sortOrder: 99));
      expect(sortAccounts(await db.getAllConfigs(), 0).map((e) => e.id), [
        3,
        1,
        2,
      ]);
      await db.setIntegerSetting(sortModeKey, 4);
      await db.setSetting(sortLockedKey, false);
      final backup = await encodeBackupAccounts(
        await db.getAllConfigs(),
        null,
        settings: await db.getSettings(),
        integerSettings: await db.getIntegerSettings(),
        includeCopyCounts: true,
      );
      await db.setIntegerSetting(sortModeKey, 1);
      await db.setSetting(sortLockedKey, true);
      await db.reorderAccounts([1, 2, 3]);
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      await container
          .read(backupOperationsProvider.notifier)
          .import(backup, null);
      expect((await db.getIntegerSettings())[sortModeKey], 4);
      expect((await db.getSettings())[sortLockedKey], false);
      expect(sortAccounts(await db.getAllConfigs(), 0).map((e) => e.id), [
        3,
        1,
        2,
      ]);
      final legacy = await encodeBackupAccounts(
        await db.getAllConfigs(),
        null,
        settings: {showCaptchaOnTapKey: false, copyCaptchaOnTapKey: false},
        integerSettings: {hideCodeAfterKey: 0},
      );
      await container
          .read(backupOperationsProvider.notifier)
          .import(legacy, null);
      expect((await db.getIntegerSettings())[sortModeKey], 4);
      expect((await db.getSettings())[sortLockedKey], false);
    },
  );

  testWidgets('sort controls and unlocked drag update the list', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await db.initializeSettings(defaultSettings);
    for (final account in accounts) {
      await db.addConfig(account);
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TokenListScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ReorderableDragStartListener), findsNothing);
    await tester.tap(find.byTooltip('Sort accounts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Name A–Z'));
    await tester.pumpAndSettle();
    expect((await db.getIntegerSettings())[sortModeKey], 1);
    final cards = tester
        .widgetList<TokenListItem>(find.byType(TokenListItem))
        .toList();
    expect(cards.first.config.issuer, 'Alpha');
    await tester.tap(find.byTooltip('Sort accounts'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Custom order'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Unlock custom order'));
    await tester.pumpAndSettle();
    expect(find.byType(ReorderableDragStartListener), findsNWidgets(3));
    await tester.drag(
      find.byType(ReorderableDragStartListener).first,
      const Offset(0, 320),
    );
    await tester.pumpAndSettle();
    expect(sortAccounts(await db.getAllConfigs(), 0).first.issuer, 'Alpha');
    await tester.enterText(find.byType(TextField), 'Alpha');
    await tester.pumpAndSettle();
    expect(find.text('Clear the search to reorder accounts.'), findsOneWidget);
    expect(find.byType(ReorderableDragStartListener), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
