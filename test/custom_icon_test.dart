import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/actions/icon_selection_provider.dart';
import 'package:authentication/backup/authpro_import.dart';
import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:authentication/storage/icon_data.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image/image.dart' as image;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'image is resized, validated, stored and restored with complete backups',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final source = AppDatabase(NativeDatabase.memory());
      final target = AppDatabase(NativeDatabase.memory());
      addTearDown(source.close);
      addTearDown(target.close);
      source.encryption = await EncryptionService.initialize(source);
      target.encryption = await EncryptionService.initialize(target);
      final input = image.Image(width: 256, height: 128);
      image.fill(input, color: image.ColorRgb8(20, 120, 200));
      final icon = makeCustomIcon(Uint8List.fromList(image.encodeJpg(input)));
      final decoded = image.decodePng(validateIcon(icon))!;
      expect(decoded.width, 128);
      expect(decoded.height, 64);
      await source.addConfig(
        OtpAccount(
          type: 'totp',
          issuer: 'Example',
          account: 'person',
          secret: 'JBSWY3DPEHPK3PXP',
          icon: icon,
        ),
      );
      final saved = (await source.getAllConfigs()).single;
      expect(saved.icon, icon);
      final backup = await encodeBackupAccounts(
        [saved],
        'test',
        settings: defaultSettings,
        integerSettings: defaultIntegerSettings,
        includeCopyCounts: true,
        categories: [],
        memberships: {saved.id: []},
      );
      final envelope = jsonDecode(utf8.decode(backup)) as Map;
      expect(envelope['version'], 6);
      final document = await decodeBackupDocument(backup, 'test');
      await target.importAccounts(
        document.accounts,
        settings: document.settings,
        integerSettings: document.integerSettings,
        importedCategories: document.categories,
        importedMemberships: document.memberships,
      );
      expect((await target.getAllConfigs()).single.icon, icon);
      await expectLater(
        decodeBackupDocument(backup, 'wrong'),
        throwsFormatException,
      );
      final plain = await encodeBackupAccounts(
        [saved],
        null,
        settings: defaultSettings,
        integerSettings: defaultIntegerSettings,
        includeCopyCounts: true,
        categories: [],
        memberships: {saved.id: []},
      );
      final damaged = jsonDecode(utf8.decode(plain)) as Map<String, dynamic>;
      ((damaged['entries'] as List).single as Map)['icon'] =
          '${customIconPrefix}AAAA';
      await expectLater(
        decodeBackupDocument(
          Uint8List.fromList(utf8.encode(jsonEncode(damaged))),
          null,
        ),
        throwsFormatException,
      );
      expect((await target.getAllConfigs()).single.icon, icon);
    },
  );

  test('migration imports new image and preserves an existing icon', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    const existing = OtpAccount(
      type: 'totp',
      issuer: 'Example',
      account: 'existing',
      secret: 'JBSWY3DPEHPK3PXP',
      icon: 'assets/icons/google.svg',
    );
    await db.addConfig(existing);
    final bitmap = image.Image(width: 16, height: 16);
    final encoded = base64Encode(image.encodePng(bitmap));
    Map<String, Object> entry(String name, String secret) => {
      'Type': 2,
      'Issuer': 'Example',
      'Username': name,
      'Secret': secret,
      'Algorithm': 0,
      'Digits': 6,
      'Period': 30,
      'Counter': 0,
      'Ranking': 0,
      'Icon': '@image',
    };
    final bytes = Uint8List.fromList(
      utf8.encode(
        jsonEncode({
          'Authenticators': [
            entry('existing', 'GEZDGNBVGY3TQOJQ'),
            entry('new', 'JBSWY3DPEHPK3PXP'),
          ],
          'CustomIcons': [
            {'Id': 'image', 'Data': encoded},
          ],
        }),
      ),
    );
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        allIconsProvider.overrideWith((ref) async => []),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(backupOperationsProvider.notifier)
        .importLegacyAccounts(parseAuthpro(bytes));
    final accounts = await db.getAllConfigs();
    expect(
      accounts.singleWhere((a) => a.account == 'existing').icon,
      'assets/icons/google.svg',
    );
    expect(
      isCustomIcon(accounts.singleWhere((a) => a.account == 'new').icon),
      isTrue,
    );
  });

  test('rejects invalid or oversized images before account writes', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    expect(
      () => makeCustomIcon(Uint8List.fromList([1, 2, 3])),
      throwsFormatException,
    );
    const account = OtpAccount(
      type: 'totp',
      issuer: 'Example',
      account: 'person',
      secret: 'JBSWY3DPEHPK3PXP',
      icon: '${customIconPrefix}AAAA',
    );
    await expectLater(db.addConfig(account), throwsFormatException);
    expect(await db.getAllConfigs(), isEmpty);
  });
}
