import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/otp/account.dart';
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
  const account = OtpAccount(
    type: 'hotp',
    issuer: 'Example',
    account: 'user',
    secret: 'JBSWY3DPEHPK3PXP',
    counter: 7,
  );
  const settings = {
    showCaptchaOnTapKey: true,
    copyCaptchaOnTapKey: false,
    showAccountNameKey: false,
  };

  test(
    'screen protection setting is backed up and old files preserve it',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      await db.setSetting(screenProtectionKey, false);
      final older = await encodeBackupAccounts(
        [account],
        null,
        settings: settings,
      );
      final olderDocument = await decodeBackupDocument(older, null);
      await db.importAccounts(
        olderDocument.accounts,
        settings: olderDocument.settings,
      );
      expect((await db.getSettings())[screenProtectionKey], false);
      final current = await encodeBackupAccounts(
        [account],
        null,
        settings: {...defaultSettings, screenProtectionKey: true},
      );
      final document = await decodeBackupDocument(current, null);
      await db.importAccounts(document.accounts, settings: document.settings);
      expect((await db.getSettings())[screenProtectionKey], true);
    },
  );

  test('system code font setting survives backup round trips', () async {
    final bytes = await encodeBackupAccounts(
      [account],
      null,
      settings: {...defaultSettings, systemCodeFontKey: true},
    );
    final decoded = await decodeBackupDocument(bytes, null);
    expect(decoded.settings![systemCodeFontKey], true);
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await db.importAccounts(decoded.accounts, settings: decoded.settings);
    expect((await db.getSettings())[systemCodeFontKey], true);
  });

  test(
    'encrypted version 3 backups preserve settings and reject damage',
    () async {
      final bytes = await encodeBackupAccounts(
        [account],
        'password',
        settings: settings,
        integerSettings: {hideCodeAfterKey: 10},
      );
      final decoded = await decodeBackupDocument(bytes, 'password');
      expect(decoded.settings, settings);
      expect(decoded.integerSettings, {hideCodeAfterKey: 10});
      expect(decoded.accounts.single.counter, 7);
      await expectLater(
        decodeBackupDocument(bytes, 'wrong'),
        throwsFormatException,
      );
      final envelope = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      envelope['version'] = 1;
      await expectLater(
        decodeBackupDocument(
          Uint8List.fromList(utf8.encode(jsonEncode(envelope))),
          'password',
        ),
        throwsFormatException,
      );
      final oldBytes = await encodeBackupAccounts([account], null);
      expect((await decodeBackupDocument(oldBytes, null)).settings, isNull);
    },
  );

  test(
    'invalid settings and failed writes leave accounts and settings unchanged',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      await db.initializeSettings(defaultSettings);
      await db.addConfig(account.copyWith(counter: 1));
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      final operations = container.read(backupOperationsProvider.notifier);
      final bytes = await encodeBackupAccounts(
        [account],
        null,
        settings: settings,
        integerSettings: {hideCodeAfterKey: 30, autoLockKey: 300},
      );
      final invalid = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      invalid['settings'] = {
        showCaptchaOnTapKey: true,
        copyCaptchaOnTapKey: 'invalid',
      };
      await expectLater(
        operations.import(
          Uint8List.fromList(utf8.encode(jsonEncode(invalid))),
          null,
        ),
        throwsFormatException,
      );
      expect(await db.getSettings(), defaultSettings);
      expect(await db.getIntegerSettings(), defaultIntegerSettings);
      expect((await db.getAllConfigs()).single.counter, 1);

      await db.customStatement('''
      CREATE TRIGGER reject_account_update BEFORE UPDATE ON auth_entries
      BEGIN SELECT RAISE(ABORT, 'test failure'); END
    ''');
      await expectLater(operations.import(bytes, null), throwsA(anything));
      expect(await db.getSettings(), defaultSettings);
      expect(await db.getIntegerSettings(), defaultIntegerSettings);
      expect((await db.getAllConfigs()).single.counter, 1);
      await db.customStatement('DROP TRIGGER reject_account_update');
      await operations.import(bytes, null);
      expect(await db.getSettings(), {
        ...settings,
        advanceHotpOnCopyKey: false,
        sortLockedKey: true,
        dynamicColorKey: true,
        backupRemindersKey: true,
        systemCodeFontKey: false,
        screenProtectionKey: true,
      });
      expect(await db.getIntegerSettings(), {
        hideCodeAfterKey: 30,
        sortModeKey: 0,
        codeGroupingKey: 0,
        themeModeKey: 0,
        accentColorKey: 0,
        languageKey: 0,
        accountViewKey: 0,
        autoLockKey: 300,
      });
      expect((await db.getAllConfigs()).single.counter, 7);
      final oldV2 = await encodeBackupAccounts(
        [account],
        null,
        settings: {showCaptchaOnTapKey: false, copyCaptchaOnTapKey: true},
      );
      await operations.import(oldV2, null);
      expect((await db.getSettings())[showAccountNameKey], isFalse);
      expect((await db.getIntegerSettings())[hideCodeAfterKey], 30);
      expect((await db.getIntegerSettings())[autoLockKey], 300);
      final badIntegers =
          jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      badIntegers['integerSettings'] = {hideCodeAfterKey: 7};
      await expectLater(
        operations.import(
          Uint8List.fromList(utf8.encode(jsonEncode(badIntegers))),
          null,
        ),
        throwsFormatException,
      );
      expect((await db.getIntegerSettings())[hideCodeAfterKey], 30);
    },
  );
}
