import 'dart:io';
import 'dart:typed_data';

import 'package:authentication/backup/automatic_backup.dart';
import 'package:authentication/backup/automatic_backup_files_io.dart';
import 'package:authentication/backup/backup.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DirectoryPicker extends FilePickerPlatform {
  DirectoryPicker(this.path);
  final String path;
  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    String? initialDirectory,
    AndroidOptions androidOptions = const AndroidOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'desktop backup creates verified encrypted files and reports lost access',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final root = await Directory.systemTemp.createTemp(
        'automatic-backup-test-',
      );
      addTearDown(() async {
        if (await root.exists()) await root.delete(recursive: true);
      });
      final target = await Directory('${root.path}/chosen').create();
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
      FilePickerPlatform.instance = DirectoryPicker(target.path);
      addTearDown(() => FilePickerPlatform.instance = original);
      ProviderContainer makeContainer() => ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          automaticBackupDesktopProvider.overrideWithValue(true),
        ],
      );
      final first = makeContainer();
      final operation = first.read(automaticBackupProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(await operation.configure('secure-password'), isTrue);
      await operation.runNow();
      expect(first.read(automaticBackupProvider), AutomaticBackupStatus.saved);
      final files = await target
          .list()
          .where((item) => item is File)
          .cast<File>()
          .toList();
      expect(files.length, 1);
      final document = await decodeBackupDocument(
        await files.single.readAsBytes(),
        'secure-password',
      );
      expect(document.accounts.single.account, 'alice');
      await expectLater(
        writeLocalBackup(
          target.path,
          files.single.uri.pathSegments.last,
          Uint8List(1),
        ),
        throwsA(isA<FileSystemException>()),
      );
      expect(
        await decodeBackupDocument(
          await files.single.readAsBytes(),
          'secure-password',
        ),
        isNotNull,
      );
      first.dispose();
      final second = makeContainer();
      second.read(automaticBackupProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(second.read(automaticBackupProvider), AutomaticBackupStatus.ready);
      await target.rename('${root.path}/moved');
      await db.createCategory('New');
      await second.read(automaticBackupProvider.notifier).runNow();
      expect(
        second.read(automaticBackupProvider),
        AutomaticBackupStatus.failed,
      );
      expect(await db.watchBackupNeeded().first, isTrue);
      expect(
        await File('${root.path}/moved/${files.single.uri.pathSegments.last}')
            .exists(),
        isTrue,
      );
      second.dispose();
      final third = makeContainer();
      addTearDown(third.dispose);
      third.read(automaticBackupProvider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(third.read(automaticBackupProvider), AutomaticBackupStatus.failed);
      await third.read(automaticBackupProvider.notifier).disable();
    },
  );
}
