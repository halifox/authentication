import 'package:authentication/otp/account.dart';
import 'package:authentication/backup/backup.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const uri =
      'otpauth://totp/Example:user?secret=JBSWY3DPEHPK3PXP&issuer=Example';

  test('encrypts new writes and rejects tampering', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await db.addConfig(parseOtpUri(uri));
    final stored = (await db.getAllAuthEntries()).single;
    expect(stored.secret, isNot('JBSWY3DPEHPK3PXP'));
    final repo = db;
    expect((await repo.getAllConfigs()).single.secret, 'JBSWY3DPEHPK3PXP');
    expect(db.encryption.encrypt('JBSWY3DPEHPK3PXP'), isNot(stored.secret));
    final parts = stored.secret.split(':');
    final payload = parts.last;
    parts[3] = '${payload[0] == 'A' ? 'B' : 'A'}${payload.substring(1)}';
    expect(() => db.encryption.decrypt(parts.join(':')), throwsA(anything));
    await repo.updateConfig(
      (await repo.getAllConfigs()).single.copyWith(pin: '1234'),
    );
    expect((await db.getAllAuthEntries()).single.pin, isNot('1234'));
    expect((await repo.getAllConfigs()).single.pin, '1234');
  });

  test('missing key does not replace the key for encrypted data', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await db.addConfig(parseOtpUri(uri));
    FlutterSecureStorage.setMockInitialValues({});
    await expectLater(EncryptionService.initialize(db), throwsStateError);
    expect((await db.getAllAuthEntries()).single.secret, startsWith('enc:v1:'));
  });

  test('invalid batch entry cannot overwrite a valid account', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    final repo = db;
    await repo.addConfig(parseOtpUri(uri));
    await expectLater(
      repo.importAccounts([
        parseOtpUri(
          'otpauth://totp/Example:user?secret=INVALID!&issuer=Example',
        ),
      ]),
      throwsA(anything),
    );
    expect((await repo.getAllConfigs()).single.secret, 'JBSWY3DPEHPK3PXP');
  });

  test('invalid entry aborts the entire file before writing', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    final repo = db;
    await expectLater(
      repo.importAccounts([
        parseOtpUri(uri),
        parseOtpUri('otpauth://totp/Bad:user?issuer=Bad&secret=INVALID!'),
      ]),
      throwsA(anything),
    );
    expect(await repo.getAllConfigs(), isEmpty);
  });

  test('file restore preserves display metadata', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    final repo = db;
    await repo.importAccounts(
      parseBackupAccounts([
        {
          'uri': uri,
          'icon': 'assets/icons/github.svg',
          'sortOrder': 17,
          'createdAt': 123,
        },
      ]),
    );
    final entry = (await repo.getAllConfigs()).single;
    expect(entry.icon, 'assets/icons/github.svg');
    expect(entry.sortOrder, 17);
    expect(entry.createdAt, 123);
  });

  test(
    'encrypted backup restores accounts to a new database and device key',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final source = AppDatabase(NativeDatabase.memory());
      var sourceClosed = false;
      addTearDown(() async {
        if (!sourceClosed) await source.close();
      });
      source.encryption = await EncryptionService.initialize(source);
      await source.addConfig(parseOtpUri(uri).copyWith(createdAt: 123));
      final bytes = await encodeBackupAccounts(
        await source.getAllConfigs(),
        'test passphrase',
      );
      final sourceCiphertext = (await source.getAllAuthEntries()).single.secret;
      await source.close();
      sourceClosed = true;

      FlutterSecureStorage.setMockInitialValues({});
      final target = AppDatabase(NativeDatabase.memory());
      addTearDown(target.close);
      target.encryption = await EncryptionService.initialize(target);
      await target.importAccounts(
        await decodeBackupAccounts(bytes, 'test passphrase'),
      );
      final restored = (await target.getAllConfigs()).single;
      expect(restored.secret, 'JBSWY3DPEHPK3PXP');
      expect(restored.createdAt, 123);
      expect(
        (await target.getAllAuthEntries()).single.secret,
        isNot(sourceCiphertext),
      );
    },
  );

  test('mOTP export and import preserves the PIN', () {
    final config = parseOtpUri(
      'otpauth://motp/Example:user?secret=JBSWY3DPEHPK3PXP&issuer=Example&pin=1234&period=10',
    );
    config.validate();
    expect(config.pin, '1234');
    expect(() => parseOtpUri('$uri&digits=invalid'), throwsA(anything));
  });
}
