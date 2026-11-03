import 'dart:typed_data';

import 'package:authentication/otp/account.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/device_key_store.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

class _InterruptedStorage extends FlutterSecureStorage {
  bool failSlotWrite = false;
  bool failDelete = false;

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    await super.write(key: key, value: value);
    if (failSlotWrite && key.startsWith('database_encryption_key_slot_')) {
      throw StateError('Simulated interrupted write');
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (failDelete) throw StateError('Simulated cleanup failure');
    await super.delete(key: key);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('reports a committed change when old key cleanup fails', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final storage = _InterruptedStorage();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await EncryptionService.initialize(db, storage: storage);
    final store = DeviceKeyStore(db, storage);
    final key = (await store.readKey())!;
    storage.failDelete = true;
    await expectLater(
      store.changePassword(deviceKey: key, newPassword: 'new-password'),
      throwsA(isA<KeyChangeCleanupFailed>()),
    );
    expect(await store.requiresPassword(), true);
    expect(await store.readKey(password: 'new-password'), key);
    expect(await storage.read(key: legacyDeviceKey), isNotNull);
    storage.failDelete = false;
    await EncryptionService.initialize(
      db,
      storage: storage,
      password: 'new-password',
    );
    expect(await storage.read(key: legacyDeviceKey), isNull);
  });
  test(
    'interrupted secure storage write leaves the original key usable',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final storage = _InterruptedStorage();
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db, storage: storage);
      await db.addConfig(
        const OtpAccount(
          type: 'totp',
          issuer: 'Example',
          account: 'alice',
          secret: 'JBSWY3DPEHPK3PXP',
        ),
      );
      final store = DeviceKeyStore(db, storage);
      final key = (await store.readKey())!;
      storage.failSlotWrite = true;
      await expectLater(
        store.changePassword(deviceKey: key, newPassword: 'new-password'),
        throwsStateError,
      );
      storage.failSlotWrite = false;
      expect(await store.requiresPassword(), false);
      final recovered = await EncryptionService.initialize(
        db,
        storage: storage,
      );
      expect(
        recovered.decrypt((await db.getAllAuthEntries()).single.secret),
        'JBSWY3DPEHPK3PXP',
      );
      final state = await db
          .customSelect('SELECT pending FROM key_state WHERE id = 1')
          .getSingle();
      expect(state.readNullable<String>('pending'), isNull);
    },
  );
  test(
    'concurrent password changes cannot both replace the active key',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      const storage = FlutterSecureStorage();
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      await EncryptionService.initialize(db, storage: storage);
      final store = DeviceKeyStore(db, storage);
      final key = (await store.readKey())!;
      final results = await Future.wait([
        for (final password in ['first-password', 'second-password'])
          store
              .changePassword(deviceKey: key, newPassword: password)
              .then((_) => password, onError: (Object _) => ''),
      ]);
      expect(results.where((result) => result.isNotEmpty).length, 1);
      final chosen = results.singleWhere((result) => result.isNotEmpty);
      expect(await store.readKey(password: chosen), key);
    },
  );
  test('password changes preserve the encrypted account and recover interrupted cleanup', () async {
    FlutterSecureStorage.setMockInitialValues({});
    const storage = FlutterSecureStorage();
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db, storage: storage);
    await db.addConfig(
      const OtpAccount(
        type: 'totp',
        issuer: 'Example',
        account: 'alice',
        secret: 'JBSWY3DPEHPK3PXP',
      ),
    );
    final encrypted = (await db.getAllAuthEntries()).single.secret;
    final store = DeviceKeyStore(db, storage);
    final key = (await store.readKey())!;
    await db.customStatement('UPDATE key_state SET previous = ?', [
      legacyDeviceKey,
    ]);
    await expectLater(
      EncryptionService.initialize(db, storage: storage),
      throwsStateError,
    );
    expect(await storage.read(key: legacyDeviceKey), isNotNull);
    await db.customStatement('UPDATE key_state SET previous = NULL');
    await db.customStatement(
      "CREATE TRIGGER reject_key_switch BEFORE UPDATE OF active ON key_state BEGIN SELECT RAISE(ABORT, 'interrupted'); END",
    );
    await expectLater(
      store.changePassword(deviceKey: key, newPassword: 'first-password'),
      throwsA(anything),
    );
    expect(
      (await EncryptionService.initialize(
        db,
        storage: storage,
      )).decrypt(encrypted),
      'JBSWY3DPEHPK3PXP',
    );
    await db.customStatement('DROP TRIGGER reject_key_switch');
    await store.changePassword(deviceKey: key, newPassword: 'first-password');
    expect(await store.requiresPassword(), true);
    expect(await storage.read(key: legacyDeviceKey), isNull);
    await expectLater(
      EncryptionService.initialize(db, storage: storage, password: 'wrong'),
      throwsFormatException,
    );
    final unlocked = await EncryptionService.initialize(
      db,
      storage: storage,
      password: 'first-password',
    );
    expect(unlocked.decrypt(encrypted), 'JBSWY3DPEHPK3PXP');
    await expectLater(
      store.changePassword(
        deviceKey: key,
        currentPassword: 'wrong',
        newPassword: 'second-password',
      ),
      throwsFormatException,
    );
    await store.changePassword(
      deviceKey: key,
      currentPassword: 'first-password',
      newPassword: 'second-password',
    );
    await expectLater(
      EncryptionService.initialize(
        db,
        storage: storage,
        password: 'first-password',
      ),
      throwsFormatException,
    );
    expect(
      (await EncryptionService.initialize(
        db,
        storage: storage,
        password: 'second-password',
      )).decrypt(encrypted),
      'JBSWY3DPEHPK3PXP',
    );
    const pending =
        'database_encryption_key_slot_00000000000000000000000000000000';
    await storage.write(key: pending, value: 'incomplete');
    await db.customStatement('UPDATE key_state SET pending = ?', [pending]);
    await expectLater(
      EncryptionService.initialize(db, storage: storage, password: 'wrong'),
      throwsFormatException,
    );
    expect(await storage.read(key: pending), 'incomplete');
    await EncryptionService.initialize(
      db,
      storage: storage,
      password: 'second-password',
    );
    expect(await storage.read(key: pending), isNull);
    await store.changePassword(
      deviceKey: key,
      currentPassword: 'second-password',
    );
    expect(await store.requiresPassword(), false);
    expect(
      (await EncryptionService.initialize(
        db,
        storage: storage,
      )).decrypt(encrypted),
      'JBSWY3DPEHPK3PXP',
    );
    expect((await db.getAllAuthEntries()).single.secret, encrypted);
    expect(key, isA<Uint8List>());
  });
}
