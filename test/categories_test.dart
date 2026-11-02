import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/category.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const alice = OtpAccount(
    type: 'hotp',
    issuer: 'Example',
    account: 'alice',
    secret: 'JBSWY3DPEHPK3PXP',
  );
  const bob = OtpAccount(
    type: 'totp',
    issuer: 'Example',
    account: 'bob',
    secret: 'JBSWY3DPEHPK3PXP',
  );
  test('category management and assignment validate and stay atomic', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await db.createCategory('Personal');
    await db.createCategory('Work');
    var categories = await db.getCategories();
    final personal = categories[0].id, work = categories[1].id;
    await expectLater(db.createCategory('Personal'), throwsA(anything));
    await expectLater(db.createCategory('  '), throwsFormatException);
    await db.setDefaultCategory(work);
    await db.addConfig(alice);
    await db.addConfig(bob);
    final accounts = await db.getAllConfigs();
    final first = accounts.first.id, second = accounts.last.id;
    expect((await db.getCategoryMemberships())[first], {work});
    await db.setAccountCategories(first, {personal, work}, expected: {work});
    await expectLater(
      db.setAccountCategories(first, {work}, expected: {work}),
      throwsStateError,
    );
    expect((await db.getCategoryMemberships())[first], {personal, work});
    await db.setCategoryAccounts(personal, {first, second}, expected: {first});
    expect((await db.getCategoryMemberships())[second], {personal, work});
    await db.renameCategory(personal, 'Home');
    await db.reorderCategories([work, personal]);
    categories = await db.getCategories();
    expect(categories.map((c) => c.name), ['Work', 'Home']);
    expect(categories.first.isDefault, isTrue);
    await db.deleteCategory(work);
    expect((await db.getCategoryMemberships())[first], {personal});
    expect((await db.getAllConfigs()).length, 2);
    expect((await db.getCategories()).single.isDefault, isFalse);
    await db.deleteConfig(first);
    expect((await db.getCategoryMemberships()).containsKey(first), isFalse);
  });
  test(
    'version 5 restores categories and associations transactionally',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      await db.initializeSettings(defaultSettings);
      await db.createCategory('Local');
      final local = (await db.getCategories()).single;
      await db.setDefaultCategory(local.id);
      await db.addConfig(alice);
      final original = (await db.getAllConfigs()).single;
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      final operations = container.read(backupOperationsProvider.notifier);
      const category = AccountCategory(
        name: 'Imported',
        sortOrder: 0,
        isDefault: true,
      );
      final bytes = await encodeBackupAccounts(
        [original.copyWith(secret: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ'), bob],
        null,
        settings: defaultSettings,
        integerSettings: defaultIntegerSettings,
        includeCopyCounts: true,
        categories: [category],
        memberships: {
          original.id: ['Imported'],
          bob.id: [],
        },
      );
      final corrupt = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      ((corrupt['entries'] as List).first as Map)['categories'] = ['Missing'];
      await expectLater(
        operations.import(
          Uint8List.fromList(utf8.encode(jsonEncode(corrupt))),
          null,
        ),
        throwsFormatException,
      );
      expect((await db.getCategories()).single.name, 'Local');
      expect((await db.getAllConfigs()).single.secret, original.secret);
      await db.customStatement(
        "CREATE TRIGGER fail_import BEFORE INSERT ON auth_entries BEGIN SELECT RAISE(ABORT, 'failure'); END",
      );
      await expectLater(operations.import(bytes, null), throwsA(anything));
      expect((await db.getCategories()).single.name, 'Local');
      expect((await db.getCategoryMemberships())[original.id], {local.id});
      expect((await db.getAllConfigs()).single.secret, original.secret);
      await db.customStatement('DROP TRIGGER fail_import');
      await operations.import(bytes, null);
      final restoredCategories = await db.getCategories();
      final imported = restoredCategories.singleWhere(
        (c) => c.name == 'Imported',
      );
      expect(imported.isDefault, isTrue);
      expect(
        restoredCategories.singleWhere((c) => c.name == 'Local').isDefault,
        isFalse,
      );
      final restored = await db.getAllConfigs();
      final restoredAlice = restored.singleWhere((a) => a.account == 'alice');
      final restoredBob = restored.singleWhere((a) => a.account == 'bob');
      expect((await db.getCategoryMemberships())[restoredAlice.id], {
        imported.id,
      });
      expect((await db.getCategoryMemberships())[restoredBob.id], isNull);
      final legacy = await encodeBackupAccounts(
        [restoredAlice],
        null,
        settings: defaultSettings,
        integerSettings: defaultIntegerSettings,
        includeCopyCounts: true,
      );
      await operations.import(legacy, null);
      expect((await db.getCategoryMemberships())[restoredAlice.id], {
        imported.id,
      });
      final empty = await encodeBackupAccounts(
        [],
        null,
        settings: defaultSettings,
        integerSettings: defaultIntegerSettings,
        includeCopyCounts: true,
        categories: [],
      );
      expect((await decodeBackupDocument(empty, null)).accounts, isEmpty);
      expect((await decodeBackupDocument(empty, null)).categories, isEmpty);
    },
  );
}
