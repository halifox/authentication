import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:authentication/storage/icon_pack.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:protobuf/protobuf.dart';

Uint8List samplePack() {
  final icon = image.Image(width: 16, height: 16);
  final entry = CodedBufferWriter()
    ..writeField(1, PbFieldType.OS, 'Example')
    ..writeField(2, PbFieldType.OY, image.encodePng(icon));
  final pack = CodedBufferWriter()
    ..writeField(1, PbFieldType.OS, 'Sample')
    ..writeField(2, PbFieldType.OS, 'Description')
    ..writeField(3, PbFieldType.OS, 'https://example.com')
    ..writeField(4, PbFieldType.OY, entry.toBuffer());
  return Uint8List.fromList(pack.toBuffer());
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('protobuf pack persists, backs up and preserves assigned icons after deletion', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final source = AppDatabase(NativeDatabase.memory());
    final target = AppDatabase(NativeDatabase.memory());
    addTearDown(source.close);
    addTearDown(target.close);
    source.encryption = await EncryptionService.initialize(source);
    target.encryption = await EncryptionService.initialize(target);
    final pack = parseIconPack(samplePack());
    expect(pack.name, 'Sample');
    expect(pack.icons.keys, ['Example']);
    await source.saveIconPack(pack);
    await source.addConfig(
      OtpAccount(
        type: 'totp',
        issuer: 'Example',
        account: 'person',
        secret: 'JBSWY3DPEHPK3PXP',
        icon: pack.icons['Example']!,
      ),
    );
    final account = (await source.getAllConfigs()).single;
    final bytes = await encodeBackupAccounts(
      [account],
      'password',
      settings: defaultSettings,
      integerSettings: defaultIntegerSettings,
      includeCopyCounts: true,
      categories: [],
      memberships: {account.id: []},
      iconPacks: await source.getIconPacks(),
    );
    expect((jsonDecode(utf8.decode(bytes)) as Map)['version'], 7);
    final restored = await decodeBackupDocument(bytes, 'password');
    await target.customStatement(
      "CREATE TRIGGER fail_account BEFORE INSERT ON auth_entries BEGIN SELECT RAISE(ABORT, 'failure'); END",
    );
    await expectLater(
      target.importAccounts(
        restored.accounts,
        settings: restored.settings,
        integerSettings: restored.integerSettings,
        importedCategories: restored.categories,
        importedMemberships: restored.memberships,
        importedIconPacks: restored.iconPacks,
      ),
      throwsA(anything),
    );
    expect(await target.getIconPacks(), isEmpty);
    expect(await target.getAllConfigs(), isEmpty);
    await target.customStatement('DROP TRIGGER fail_account');
    await target.importAccounts(
      restored.accounts,
      settings: restored.settings,
      integerSettings: restored.integerSettings,
      importedCategories: restored.categories,
      importedMemberships: restored.memberships,
      importedIconPacks: restored.iconPacks,
    );
    expect((await target.getIconPacks()).single.icons, pack.icons);
    await target.deleteIconPack('Sample');
    expect(await target.getIconPacks(), isEmpty);
    expect((await target.getAllConfigs()).single.icon, account.icon);
    await expectLater(
      decodeBackupDocument(bytes, 'wrong'),
      throwsFormatException,
    );
  });

  test('rejects invalid protobuf and corrupt images', () {
    expect(
      () => parseIconPack(Uint8List.fromList([1, 2, 3])),
      throwsFormatException,
    );
    final entry = CodedBufferWriter()
      ..writeField(1, PbFieldType.OS, 'bad')
      ..writeField(2, PbFieldType.OY, [1, 2, 3]);
    final pack = CodedBufferWriter()
      ..writeField(1, PbFieldType.OS, 'pack')
      ..writeField(4, PbFieldType.OY, entry.toBuffer());
    expect(
      () => parseIconPack(Uint8List.fromList(pack.toBuffer())),
      throwsFormatException,
    );
  });
}
