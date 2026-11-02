import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/actions/account_actions.dart';
import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/otp/otp_provider.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('account and backup operations expose state through Riverpod', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final accountOps = container.read(accountOperationsProvider.notifier);
    final pending = accountOps.save(
      id: null,
      type: 'totp',
      issuer: 'Example',
      account: 'user',
      secret: 'JBSWY3DPEHPK3PXP',
      algorithm: 'sha1',
      digits: 6,
      period: 30,
      counter: 0,
      pin: '',
      icon: 'assets/icons/passkey.svg',
    );
    expect(container.read(accountOperationsProvider).isLoading, isTrue);
    expect(await pending, isA<TokenFormSuccess>());
    expect(container.read(accountOperationsProvider).hasValue, isTrue);
    expect((await db.getAllConfigs()).single.account, 'user');

    final backupOps = container.read(backupOperationsProvider.notifier);
    final uri =
        'otpauth://hotp/Example:user?secret=JBSWY3DPEHPK3PXP&issuer=Example&counter=7';
    final before = (await db.getAllConfigs()).single;
    await backupOps.importUriFile(Uint8List.fromList(utf8.encode(uri)));
    final updated = (await db.getAllConfigs()).single;
    expect(updated.counter, 7);
    expect(updated.createdAt, before.createdAt);
    expect(updated.icon, before.icon);
    await expectLater(
      backupOps.importUriFile(Uint8List.fromList(utf8.encode('$uri\n$uri'))),
      throwsFormatException,
    );
    expect((await db.getAllConfigs()).single.counter, 7);

    await expectLater(
      backupOps.import(Uint8List.fromList([1, 2, 3]), null),
      throwsA(anything),
    );
    expect(container.read(backupOperationsProvider).hasError, isTrue);
    expect((await db.getAllConfigs()).single.account, 'user');
  });
}
