import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:authentication/actions/icon_selection_provider.dart';
import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/backup/legacy_import.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/category.dart';
import 'package:authentication/screens/add_account_screen.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:base32/base32.dart';
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
  testWidgets('encrypted grouped backup decrypts before confirmation', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    final bytes = File('test/fixtures/grouped_backup/encrypted.json')
        .readAsBytesSync();
    final original = FilePickerPlatform.instance;
    FilePickerPlatform.instance = _MemoryPicker(bytes);
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
      find.text('Import Aegis backup'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Import Aegis backup'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'test');
    await tester.pump();
    await tester.tap(find.text('OK'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Decrypting backup. Please wait.'), findsOneWidget);
    expect(await db.getAllConfigs(), isEmpty);
    await tester.runAsync(() async {
      await Future<void>.delayed(const Duration(seconds: 2));
    });
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Source groups merge into categories'),
      findsOneWidget,
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect((await db.getAllConfigs()).length, 7);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
  testWidgets('grouped backup shows conflict policy before importing', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    final bytes = File('test/fixtures/grouped_backup/grouped-v2.json')
        .readAsBytesSync();
    final original = FilePickerPlatform.instance;
    FilePickerPlatform.instance = _MemoryPicker(bytes);
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
      find.text('Import Aegis backup'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Import Aegis backup'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Source groups merge into categories'),
      findsOneWidget,
    );
    expect(await db.getAllConfigs(), isEmpty);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect((await db.getAllConfigs()).length, 7);
    expect(
      (await db.getCategories()).map((c) => c.name),
      containsAll(['group1', 'group2']),
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
  test('vault JSON extracts codes, folders and skipped item counts', () {
    Uint8List bytes(Object value) =>
        Uint8List.fromList(utf8.encode(jsonEncode(value)));
    final vault = {
      'encrypted': false,
      'folders': [
        {'id': 'folder1', 'name': 'Work'},
      ],
      'items': [
        {
          'type': 1,
          'name': 'Example',
          'folderId': 'folder1',
          'login': {
            'username': 'user',
            'password': 'not imported',
            'totp': 'otpauth://totp/Example:user?secret=JBSWY3DPEHPK3PXP&issuer=Example',
          },
        },
        {
          'type': 1,
          'name': 'Other',
          'login': {'username': 'other', 'totp': 'JBSWY3DPEHPK3PXP'},
        },
        {
          'type': 1,
          'name': 'No code',
          'login': {'totp': null},
        },
        {'type': 2, 'name': 'Secure note'},
      ],
    };
    final parsed = parseVaultBackup(bytes(vault));
    expect(parsed.document.accounts.length, 2);
    expect(parsed.skipped, 2);
    expect(parsed.document.memberships[('Example', 'user')], ['Work']);
    expect(parsed.document.accounts.last.issuer, 'Other');
    expect(parsed.document.accounts.last.account, 'other');
    expect(
      () => parseVaultBackup(bytes({...vault, 'encrypted': true})),
      throwsFormatException,
    );
    final first = (vault['items'] as List).first;
    expect(
      () => parseVaultBackup(
        bytes({
          ...vault,
          'items': [first, first],
        }),
      ),
      throwsFormatException,
    );
    expect(
      () => parseVaultBackup(bytes({...vault, 'folders': []})),
      throwsFormatException,
    );
  });
  testWidgets(
    'vault import explains skipped items and only writes after confirmation',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      final json = {
        'encrypted': false,
        'items': [
          {
            'type': 1,
            'name': 'Example',
            'login': {'username': 'user', 'totp': 'JBSWY3DPEHPK3PXP'},
          },
          {'type': 2, 'name': 'note'},
        ],
      };
      final original = FilePickerPlatform.instance;
      FilePickerPlatform.instance = _MemoryPicker(
        Uint8List.fromList(utf8.encode(jsonEncode(json))),
      );
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
        find.text('Import Bitwarden JSON'),
        200,
        scrollable: find.byType(Scrollable),
      );
      await tester.tap(find.text('Import Bitwarden JSON'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Import 1 verification accounts and skip 1'),
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
  test('token list format validates ordering, signed bytes and metadata', () {
    Uint8List data(Object value) =>
        Uint8List.fromList(utf8.encode(jsonEncode(value)));
    final first = {
      'issuerInt': 'internal',
      'issuerExt': 'External',
      'issuerAlt': 'Displayed',
      'label': 'raw',
      'labelAlt': 'shown',
      'type': 'HOTP',
      'algo': 'SHA1',
      'digits': 6,
      'counter': 7,
      'period': 30,
      'secret': [-128, -1, 0, 1, 127],
      'category': 'Work',
    };
    final second = {
      'issuerExt': 'Other',
      'label': 'user',
      'type': 'TOTP',
      'algo': 'SHA256',
      'digits': 8,
      'counter': 0,
      'period': 60,
      'secret': [1, 2, 3, 4, 5],
      'category': '',
    };
    final backup = {
      'tokens': [first, second],
      'tokenOrder': ['Other:user', 'internal:raw'],
    };
    final result = parseTokenListBackup(data(backup));
    expect(result.accounts.map((account) => account.account), [
      'user',
      'shown',
    ]);
    expect(result.accounts.last.issuer, 'Displayed');
    expect(result.accounts.last.counter, 7);
    expect(base32.decode(result.accounts.last.secret), [128, 255, 0, 1, 127]);
    expect(result.memberships[('Displayed', 'shown')], ['Work']);
    expect(
      () => parseTokenListBackup(
        data({
          ...backup,
          'tokenOrder': ['Other:user', 'missing'],
        }),
      ),
      throwsFormatException,
    );
    expect(
      () => parseTokenListBackup(
        data({
          ...backup,
          'tokenOrder': ['Other:user', 'Other:user'],
        }),
      ),
      throwsFormatException,
    );
    expect(
      () => parseTokenListBackup(
        data({
          ...backup,
          'tokens': [
            first,
            {
              ...second,
              'secret': [256],
            },
          ],
        }),
      ),
      throwsFormatException,
    );
  });
  testWidgets('token list file imports only after confirmation', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    final json = {
      'tokens': [
        {
          'issuerExt': 'Example',
          'label': 'user',
          'type': 'HOTP',
          'algo': 'SHA1',
          'digits': 6,
          'counter': 2,
          'period': 30,
          'secret': [1, 2, 3, 4, 5],
          'category': 'Work',
        },
      ],
      'tokenOrder': ['Example:user'],
    };
    final original = FilePickerPlatform.instance;
    FilePickerPlatform.instance = _MemoryPicker(
      Uint8List.fromList(utf8.encode(jsonEncode(json))),
    );
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
      find.text('Import FreeOTP+ backup'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Import FreeOTP+ backup'));
    await tester.pumpAndSettle();
    expect(await db.getAllConfigs(), isEmpty);
    expect(find.textContaining('Source categories are merged'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    final account = (await db.getAllConfigs()).single;
    expect(account.counter, 2);
    final category = (await db.getCategories()).single;
    expect(category.name, 'Work');
    expect((await db.getCategoryMemberships())[account.id], {category.id});
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
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
          'Source categories are merged by name; source icons and usage statistics are not imported.',
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
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.text('Decrypting backup. Please wait.'), findsOneWidget);
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
      container.read(backupOperationsProvider.notifier).importLegacyAccounts((
        accounts: [
          initial.copyWith(counter: 9),
          initial.copyWith(account: 'new'),
        ],
        categories: [const AccountCategory(name: 'Created')],
        memberships: {
          ('Example', 'existing'): ['Created'],
          ('Example', 'new'): ['Created'],
        },
      )),
      throwsA(anything),
    );
    final account = (await db.getAllConfigs()).single;
    expect(account.counter, 1);
    expect(account.icon, 'assets/icons/google.svg');
    expect(await db.getCategories(), isEmpty);
  });
  test(
    'tag import merges category names and preserves defaults and memberships',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      await db.createCategory('Local');
      await db.createCategory('Work');
      final originalCategories = await db.getCategories();
      final local = originalCategories.first;
      final work = originalCategories.last;
      await db.setDefaultCategory(local.id);
      const existing = OtpAccount(
        type: 'totp',
        issuer: 'Example',
        account: 'existing',
        secret: 'JBSWY3DPEHPK3PXP',
      );
      await db.addConfig(existing);
      final json = [
        {
          'issuer': 'Example',
          'label': 'existing',
          'secret': 'JBSWY3DPEHPK3PXP',
          'tags': ['Work', 'Work'],
        },
        {
          'issuer': 'Example',
          'label': 'new',
          'secret': 'JBSWY3DPEHPK3PXP',
          'tags': ['Work', 'New'],
        },
      ];
      final document = parseLegacyBackup(
        Uint8List.fromList(utf8.encode(jsonEncode(json))),
      );
      final container = ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          allIconsProvider.overrideWith((ref) async => []),
        ],
      );
      addTearDown(container.dispose);
      expect(
        await container
            .read(backupOperationsProvider.notifier)
            .importLegacyAccounts(document),
        2,
      );
      final categories = await db.getCategories();
      expect(categories.map((category) => category.name), [
        'Local',
        'Work',
        'New',
      ]);
      expect(
        categories.singleWhere((category) => category.isDefault).id,
        local.id,
      );
      expect(categories[1].sortOrder, work.sortOrder);
      final accounts = await db.getAllConfigs();
      final memberships = await db.getCategoryMemberships();
      expect(
        memberships[accounts.singleWhere((a) => a.account == 'existing').id],
        {local.id, work.id},
      );
      expect(memberships[accounts.singleWhere((a) => a.account == 'new').id], {
        local.id,
        work.id,
        categories.last.id,
      });
    },
  );
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
    expect(accounts.accounts.length, 2);
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
    final account = parseLegacyBackup(data([valid])).accounts.single;
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
      () => parseLegacyBackup(
        data([
          {
            ...valid,
            'tags': ['  '],
          },
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
