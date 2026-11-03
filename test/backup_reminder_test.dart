import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/screens/settings_screen.dart';
import 'package:authentication/screens/token_list_screen.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _SavePicker extends FilePickerPlatform {
  Uri? result;
  Future<void> Function()? onSave;
  @override
  Future<Uri?> saveFile({
    required String fileName,
    required Uint8List bytes,
    required String mimeType,
    String? dialogTitle,
    String? initialDirectory,
    void Function(FilePickerStatus)? onFileSaving,
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async {
    await onSave?.call();
    return result;
  }
}

void main() {
  test(
    'encrypted snapshot captures account metadata and its revision',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      await db.addConfig(
        const OtpAccount(
          type: 'totp',
          issuer: 'Example',
          account: 'alice',
          secret: 'JBSWY3DPEHPK3PXP',
        ),
      );
      final account = (await db.getAllConfigs()).single;
      await db.createCategory('Work');
      final category = (await db.getCategories()).single;
      await db.setAccountCategories(account.id, {category.id});
      await db.setSetting(showAccountNameKey, false);
      final snapshot = await createBackupSnapshot(db, 'test-password');
      expect(snapshot.revision, await db.backupRevision());
      await db.createCategory('Added later');
      final document = await decodeBackupDocument(
        snapshot.bytes,
        'test-password',
      );
      expect(document.accounts.single.secret, account.secret);
      expect(document.categories!.map((item) => item.name), ['Work']);
      expect(document.memberships![('Example', 'alice')], ['Work']);
      expect(document.settings![showAccountNameKey], false);
      await expectLater(
        decodeBackupDocument(snapshot.bytes, 'wrong-password'),
        throwsFormatException,
      );
      await db.markBackupSaved(snapshot.revision);
      expect(await db.watchBackupNeeded().first, true);
    },
  );
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('reminder follows data changes and its setting', (tester) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
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
    expect(find.text('Your data has changed. Create a backup.'), findsNothing);
    await db.addConfig(
      const OtpAccount(
        type: 'totp',
        issuer: 'Example',
        account: 'alice',
        secret: 'JBSWY3DPEHPK3PXP',
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Your data has changed. Create a backup.'),
      findsOneWidget,
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Backup reminders'));
    final tile = find.ancestor(
      of: find.text('Backup reminders'),
      matching: find.byType(SettingsSwitchTile),
    );
    await tester.tap(
      find.descendant(of: tile, matching: find.byType(GestureDetector)),
    );
    await tester.pumpAndSettle();
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
    expect(find.text('Your data has changed. Create a backup.'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
  test('only a successful save acknowledges the exported snapshot', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await db.addConfig(
      const OtpAccount(
        type: 'totp',
        issuer: 'Example',
        account: 'alice',
        secret: 'JBSWY3DPEHPK3PXP',
      ),
    );
    final original = FilePickerPlatform.instance;
    final picker = _SavePicker();
    FilePickerPlatform.instance = picker;
    addTearDown(() => FilePickerPlatform.instance = original);
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWithValue(db)],
    );
    addTearDown(container.dispose);
    final operations = container.read(backupOperationsProvider.notifier);
    expect(await operations.exportFile(null), false);
    expect(await db.watchBackupNeeded().first, true);
    picker.result = Uri.file('/tmp/backup.json');
    picker.onSave = () => db.createCategory('During save');
    expect(await operations.exportFile(null), true);
    expect(await db.watchBackupNeeded().first, true);
    picker.onSave = null;
    expect(await operations.exportFile(null), true);
    expect(await db.watchBackupNeeded().first, false);
  });
  test('backup revision tracks committed changes and snapshot races', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    expect(await db.watchBackupNeeded().first, false);
    await db.addConfig(
      const OtpAccount(
        type: 'totp',
        issuer: 'Example',
        account: 'alice',
        secret: 'JBSWY3DPEHPK3PXP',
      ),
    );
    expect(await db.watchBackupNeeded().first, true);
    final snapshot = await db.backupRevision();
    await db.createCategory('Work');
    await db.markBackupSaved(snapshot);
    expect(await db.watchBackupNeeded().first, true);
    final newer = await db.backupRevision();
    await db.markBackupSaved(newer);
    expect(await db.watchBackupNeeded().first, false);
    await db.markBackupSaved(snapshot);
    expect(await db.watchBackupNeeded().first, true);
    await expectLater(db.markBackupSaved(newer + 1), throwsArgumentError);
    expect(await db.watchBackupNeeded().first, true);
    await db.markBackupSaved(newer);
    expect(await db.watchBackupNeeded().first, false);
    await expectLater(
      db.transaction(() async {
        await db.createCategory('Rolled back');
        throw StateError('rollback');
      }),
      throwsStateError,
    );
    expect(await db.backupRevision(), newer);
    expect(await db.watchBackupNeeded().first, false);
    await db.deleteConfig((await db.getAllConfigs()).single.id);
    expect(await db.watchBackupNeeded().first, true);
  });
}
