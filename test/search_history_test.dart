import 'dart:io';

import 'package:authentication/otp/account.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'history is encrypted, bounded, deduplicated and separate from backups',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      await db.addConfig(
        const OtpAccount(
          type: 'hotp',
          issuer: 'Example',
          account: 'alice',
          secret: 'JBSWY3DPEHPK3PXP',
        ),
      );
      final revision = await db.backupRevision();
      await db.rememberSearch(' Example ');
      await db.rememberSearch('Other');
      await db.rememberSearch('example');
      expect(await db.watchRecentSearches().first, ['example', 'Other']);
      final stored = await db
          .customSelect('SELECT encrypted_query FROM recent_searches')
          .get();
      for (final row in stored) {
        expect(row.read<String>('encrypted_query'), startsWith('enc:v1:'));
        expect(row.read<String>('encrypted_query'), isNot(contains('example')));
      }
      for (var i = 0; i < 25; i++) {
        await db.rememberSearch('Query $i');
      }
      final latest = await db.watchRecentSearches().first;
      expect(latest.length, 20);
      expect(latest.first, 'Query 24');
      expect(latest.last, 'Query 5');
      await db.removeRecentSearch('Query 24');
      expect(await db.watchRecentSearches().first, isNot(contains('Query 24')));
      await expectLater(db.rememberSearch('   '), throwsFormatException);
      await expectLater(db.rememberSearch('x' * 129), throwsFormatException);
      await db.clearRecentSearches();
      expect(await db.watchRecentSearches().first, isEmpty);
      expect(await db.backupRevision(), revision);
      expect((await db.getAllConfigs()).single.account, 'alice');
    },
  );

  test(
    'version 8 upgrades preserve encrypted accounts and create empty history',
    () async {
      final db = AppDatabase(
        NativeDatabase.memory(
          setup: (sqlite) {
            sqlite.execute(
              'CREATE TABLE auth_entries (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, scheme TEXT NOT NULL, type TEXT NOT NULL, issuer TEXT NOT NULL, account TEXT NOT NULL, secret TEXT NOT NULL, algorithm TEXT NOT NULL, digits INTEGER NOT NULL, period INTEGER NOT NULL, counter INTEGER NOT NULL, pin TEXT NOT NULL, icon TEXT NOT NULL, sort_order INTEGER NOT NULL, created_at INTEGER NOT NULL, copy_count INTEGER NOT NULL DEFAULT 0, UNIQUE (issuer, account))',
            );
            sqlite.execute(
              "INSERT INTO auth_entries VALUES (1, 'otpauth', 'totp', 'Example', 'alice', 'enc:v1:unchanged', 'sha1', 6, 30, 0, '', '', 3, 10, 7)",
            );
            sqlite.execute('PRAGMA user_version = 8');
          },
        ),
      );
      addTearDown(db.close);
      final account = (await db.getAllAuthEntries()).single;
      expect(account.secret, 'enc:v1:unchanged');
      expect(account.sortOrder, 3);
      expect(account.copyCount, 7);
      expect(await db.watchRecentSearches().first, isEmpty);
    },
  );

  test(
    'missing device key never replaces the key for history-only storage',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      await db.rememberSearch('Example');
      FlutterSecureStorage.setMockInitialValues({});
      await expectLater(EncryptionService.initialize(db), throwsStateError);
      expect(
        await const FlutterSecureStorage().read(
          key: 'database_encryption_key_v1',
        ),
        isNull,
      );
    },
  );

  test('encrypted recent searches survive a database restart', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final directory = await Directory.systemTemp.createTemp('auth-search-');
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/history.sqlite');
    final first = AppDatabase(NativeDatabase(file));
    first.encryption = await EncryptionService.initialize(first);
    await first.rememberSearch('Example');
    await first.close();
    final second = AppDatabase(NativeDatabase(file));
    addTearDown(second.close);
    second.encryption = await EncryptionService.initialize(second);
    expect(await second.watchRecentSearches().first, ['Example']);
  });
}
