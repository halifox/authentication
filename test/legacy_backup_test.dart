import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:authentication/actions/icon_selection_provider.dart';
import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/backup/legacy_import.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/screens/add_account_screen.dart';
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

final class _MemoryFile extends PlatformFile {
  _MemoryFile(this.bytes);
  final Uint8List bytes;
  @override
  String get name => 'backup.json';
  @override
  Uri get uri => Uri.parse('memory:backup');
  @override
  Never get xFile => throw UnimplementedError();
  @override
  int? lengthSync() => bytes.length;
  @override
  Future<int?> length() async => bytes.length;
  @override
  Future<Uint8List> readAsBytes() async => bytes;
  @override
  Stream<Uint8List> readAsByteStream() => Stream.value(bytes);
}

class _MemoryPicker extends FilePickerPlatform {
  _MemoryPicker(this.bytes);
  final Uint8List bytes;
  @override
  Future<PlatformFile?> pickFile({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    void Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    AndroidOptions androidOptions = const AndroidOptions(),
    DarwinOptions darwinOptions = const DarwinOptions(),
    WindowsOptions windowsOptions = const WindowsOptions(),
    LinuxOptions linuxOptions = const LinuxOptions(),
    WebOptions webOptions = const WebOptions(),
  }) async => _MemoryFile(bytes);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'plain file import requires confirmation before database writes',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      final file = Uint8List.fromList(
        utf8.encode(
          jsonEncode([
            {
              'issuer': 'Example',
              'label': 'user',
              'secret': 'JBSWY3DPEHPK3PXP',
              'type': 'TOTP',
              'algorithm': 'SHA1',
              'digits': 6,
              'period': 30,
            },
          ]),
        ),
      );
      final original = FilePickerPlatform.instance;
      FilePickerPlatform.instance = _MemoryPicker(file);
      addTearDown(() => FilePickerPlatform.instance = original);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            allIconsProvider.overrideWith((ref) async => []),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AddAccountScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Import andOTP backup'),
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text('Import andOTP backup'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Plain JSON'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining(
          'Source tags, icons, and usage statistics are not imported.',
        ),
        findsOneWidget,
      );
      expect(await db.getAllConfigs(), isEmpty);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect((await db.getAllConfigs()).single.account, 'user');
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    },
  );
  testWidgets(
    'encrypted import handles a password and safely rejects invalid accounts',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      final bytes = File('test/fixtures/legacy_backup/accounts.aes')
          .readAsBytesSync();
      final original = FilePickerPlatform.instance;
      FilePickerPlatform.instance = _MemoryPicker(bytes);
      addTearDown(() => FilePickerPlatform.instance = original);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appDatabaseProvider.overrideWithValue(db)],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: AddAccountScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Import andOTP backup'),
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text('Import andOTP backup'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Encrypted backup (0.6.3 or later)'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '123456');
      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField)).obscureText,
        false,
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(seconds: 2));
      });
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Import failed. Check the file'),
        findsOneWidget,
      );
      expect(await db.getAllConfigs(), isEmpty);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    },
  );
  test('failed batch import rolls back prior updates', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    const initial = OtpAccount(
      type: 'hotp',
      issuer: 'Example',
      account: 'existing',
      secret: 'JBSWY3DPEHPK3PXP',
      counter: 1,
      icon: 'assets/icons/google.svg',
    );
    await db.addConfig(initial);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        allIconsProvider.overrideWith((ref) async => []),
      ],
    );
    addTearDown(container.dispose);
    await db.customStatement(
      "CREATE TRIGGER reject_import BEFORE INSERT ON auth_entries BEGIN SELECT RAISE(ABORT, 'test failure'); END",
    );
    await expectLater(
      container.read(backupOperationsProvider.notifier).importLegacyAccounts([
        initial.copyWith(counter: 9),
        initial.copyWith(account: 'new'),
      ]),
      throwsA(anything),
    );
    final account = (await db.getAllConfigs()).single;
    expect(account.counter, 1);
    expect(account.icon, 'assets/icons/google.svg');
  });
  test('decrypts independent old and current encrypted samples', () async {
    for (final sample in [
      (LegacyBackupFormat.encryptedOld, 'old.aes'),
      (LegacyBackupFormat.encrypted, 'current.aes'),
    ]) {
      final bytes = await File('test/fixtures/legacy_backup/${sample.$2}')
          .readAsBytes();
      final plaintext = await decryptLegacyBackup(
        bytes,
        sample.$1,
        password: '123456',
      );
      final data = jsonDecode(utf8.decode(plaintext)) as List;
      expect(data.single['label'], 'test');
      await expectLater(
        decryptLegacyBackup(bytes, sample.$1, password: 'wrong'),
        throwsFormatException,
      );
      final damaged = Uint8List.fromList(bytes)..[bytes.length - 1] ^= 1;
      await expectLater(
        decryptLegacyBackup(damaged, sample.$1, password: '123456'),
        throwsFormatException,
      );
    }
  });
  test('parses issuer-bearing independent encrypted sample', () async {
    final bytes = await File('test/fixtures/legacy_backup/accounts.aes')
        .readAsBytes();
    final plaintext = await decryptLegacyBackup(
      bytes,
      LegacyBackupFormat.encrypted,
      password: '123456',
    );
    final sample = jsonDecode(utf8.decode(plaintext)) as List;
    expect(() => parseLegacyBackup(plaintext), throwsFormatException);
    final valid = Uint8List.fromList(
      utf8.encode(jsonEncode(sample.take(2).toList())),
    );
    final accounts = parseLegacyBackup(valid);
    expect(accounts.length, 2);
  });
  test('validates whole input and rejects unsupported entries', () {
    Uint8List data(Object object) =>
        Uint8List.fromList(utf8.encode(jsonEncode(object)));
    final valid = {
      'issuer': 'Example',
      'label': 'user',
      'secret': 'JBSWY3DPEHPK3PXP',
      'type': 'TOTP',
      'algorithm': 'SHA256',
      'digits': 8,
      'period': 60,
    };
    final account = parseLegacyBackup(data([valid])).single;
    expect(account.algorithm, 'sha256');
    expect(account.period, 60);
    expect(
      () => parseLegacyBackup(
        data([
          valid,
          {...valid, 'type': 'MOTP'},
        ]),
      ),
      throwsFormatException,
    );
    expect(
      () => parseLegacyBackup(data([valid, valid])),
      throwsFormatException,
    );
    expect(
      () => parseLegacyBackup(
        data([
          {...valid, 'issuer': ''},
        ]),
      ),
      throwsFormatException,
    );
  });
}
