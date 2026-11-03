import 'dart:typed_data';

import 'package:authentication/backup/automatic_backup.dart';
import 'package:authentication/backup/backup.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/screens/settings_screen.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saf/saf.dart';

class MemorySaf extends SafPlatform {
  final files = <String, Uint8List>{};
  bool failWrite = false;
  bool corruptRead = false;
  bool grant = true;
  bool cancelPick = false;
  Future<void> Function()? onWrite;
  String directory =
      'content://com.android.externalstorage.documents/tree/primary%3ADocuments/document/primary%3ADocuments';
  SafDocumentFile document(String uri, {bool isDir = false}) => SafDocumentFile(
    uri: uri,
    name: 'test',
    isDir: isDir,
    length: 0,
    lastModified: 0,
  );

  @override
  Future<SafDocumentFile?> pickDirectory({
    String? initialUri,
    bool writePermission = true,
    bool persistablePermission = true,
  }) async => cancelPick ? null : document(directory, isDir: true);

  @override
  Future<SafDocumentFile> writeFileStream(
    String dirUri,
    String name,
    String mime,
    Stream<List<int>> source, {
    bool overwrite = false,
    bool append = false,
  }) async {
    if (failWrite) throw StateError('private error');
    final builder = BytesBuilder();
    await for (final chunk in source) {
      builder.add(chunk);
    }
    await onWrite?.call();
    final uri = '$dirUri/$name';
    files[uri] = builder.takeBytes();
    return document(uri);
  }

  @override
  Future<Uint8List> readFileBytes(String uri, {int? start, int? count}) async =>
      corruptRead ? Uint8List(0) : files[uri]!;
  @override
  Future<void> delete(String uri) async {
    files.remove(uri);
  }

  @override
  Future<void> releasePersistedPermission(String uri) async {}

  @override
  Future<List<SafPersistedPermission>> persistedPermissions() async => grant
      ? [
          const SafPersistedPermission(
            uri: 'content://com.android.externalstorage.documents/tree/primary%3ADocuments',
            read: true,
            write: true,
            persistedTime: 0,
          ),
        ]
      : [];
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('unsupported platforms explain the limitation', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [automaticBackupSupportedProvider.overrideWithValue(false)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AutomaticBackupScreen(),
        ),
      ),
    );
    expect(
      find.text('Automatic backup is not available on this platform.'),
      findsWidgets,
    );
    expect(find.byType(TextField), findsNothing);
  });
  testWidgets('setup requires matching passwords and enables local folder', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    final original = SafPlatform.instance;
    SafPlatform.instance = MemorySaf();
    addTearDown(() => SafPlatform.instance = original);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          automaticBackupSupportedProvider.overrideWithValue(true),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AutomaticBackupScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final button = find.widgetWithText(
      FilledButton,
      'Choose folder and enable',
    );
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    await tester.enterText(find.byType(TextField).first, 'secure-password');
    await tester.enterText(find.byType(TextField).last, 'wrong');
    await tester.pump();
    expect(tester.widget<FilledButton>(button).onPressed, isNull);
    await tester.enterText(find.byType(TextField).last, 'secure-password');
    await tester.pump();
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 10));
    expect(find.text('Automatic backup is enabled.'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField).first).controller!.text,
      isEmpty,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
  test('automatic backup encrypts, verifies, retries, and disables', () async {
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
    final original = SafPlatform.instance;
    final saf = MemorySaf();
    SafPlatform.instance = saf;
    addTearDown(() => SafPlatform.instance = original);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        automaticBackupSupportedProvider.overrideWithValue(true),
      ],
    );
    addTearDown(container.dispose);
    final operation = container.read(automaticBackupProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(
      container.read(automaticBackupProvider),
      AutomaticBackupStatus.disabled,
    );
    final localDirectory = saf.directory;
    saf.directory = 'content://example.cloud/tree/remote';
    expect(await operation.configure('secure-password'), false);
    expect(
      container.read(automaticBackupProvider),
      AutomaticBackupStatus.failed,
    );
    expect(saf.files, isEmpty);
    saf.directory = localDirectory;
    saf.grant = false;
    expect(await operation.configure('secure-password'), false);
    expect(saf.files, isEmpty);
    saf.grant = true;
    expect(await operation.configure('secure-password'), true);
    await operation.runNow();
    expect(
      container.read(automaticBackupProvider),
      AutomaticBackupStatus.saved,
    );
    expect(saf.files.length, 1);
    final document = await decodeBackupDocument(
      saf.files.values.single,
      'secure-password',
    );
    expect(document.accounts.single.account, 'alice');
    expect(await db.watchBackupNeeded().first, false);
    await db.createCategory('Changed');
    saf.failWrite = true;
    await operation.runNow();
    expect(
      container.read(automaticBackupProvider),
      AutomaticBackupStatus.failed,
    );
    expect(await db.watchBackupNeeded().first, true);
    expect(saf.files.length, 1);
    saf.failWrite = false;
    saf.corruptRead = true;
    await operation.runNow();
    expect(
      container.read(automaticBackupProvider),
      AutomaticBackupStatus.failed,
    );
    expect(saf.files.length, 1);
    saf.corruptRead = false;
    await operation.runNow();
    expect(
      container.read(automaticBackupProvider),
      AutomaticBackupStatus.saved,
    );
    expect(saf.files.length, 2);
    expect(await db.watchBackupNeeded().first, false);
    await operation.disable();
    expect(
      container.read(automaticBackupProvider),
      AutomaticBackupStatus.disabled,
    );
  });

  test(
    'restores configuration and schedules changes made during a write',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      final original = SafPlatform.instance;
      final saf = MemorySaf();
      SafPlatform.instance = saf;
      addTearDown(() => SafPlatform.instance = original);
      ProviderContainer makeContainer() => ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          automaticBackupSupportedProvider.overrideWithValue(true),
        ],
      );
      final first = makeContainer();
      final firstOperation = first.read(automaticBackupProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(await firstOperation.configure('secure-password'), true);
      first.dispose();
      final second = makeContainer();
      addTearDown(second.dispose);
      final operation = second.read(automaticBackupProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(second.read(automaticBackupProvider), AutomaticBackupStatus.ready);
      saf.onWrite = () async {
        saf.onWrite = null;
        await db.createCategory('During save');
      };
      await operation.runNow();
      expect(await db.watchBackupNeeded().first, true);
      for (var i = 0; i < 100 && saf.files.length < 2; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      expect(saf.files.length, 2);
      for (
        var i = 0;
        i < 30 &&
            second.read(automaticBackupProvider) ==
                AutomaticBackupStatus.saving;
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      expect(await db.watchBackupNeeded().first, false);
      await operation.disable();
    },
  );
  test('cancelling folder selection preserves a pending backup', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    final original = SafPlatform.instance;
    final saf = MemorySaf();
    SafPlatform.instance = saf;
    addTearDown(() => SafPlatform.instance = original);
    final container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWithValue(db),
        automaticBackupSupportedProvider.overrideWithValue(true),
      ],
    );
    addTearDown(container.dispose);
    final operation = container.read(automaticBackupProvider.notifier);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    expect(await operation.configure('secure-password'), true);
    await operation.runNow();
    await db.createCategory('Pending');
    await Future<void>.delayed(const Duration(milliseconds: 100));
    saf.cancelPick = true;
    expect(await operation.configure('new-password'), false);
    for (var i = 0; i < 100 && saf.files.length < 2; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    expect(saf.files.length, 2);
    for (
      var i = 0;
      i < 30 &&
          container.read(automaticBackupProvider) ==
              AutomaticBackupStatus.saving;
      i++
    ) {
      await Future<void>.delayed(const Duration(milliseconds: 100));
    }
    await operation.disable();
  });

  test(
    'retry after a missing startup grant resumes automatic scheduling',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      final original = SafPlatform.instance;
      final saf = MemorySaf();
      SafPlatform.instance = saf;
      addTearDown(() => SafPlatform.instance = original);
      ProviderContainer makeContainer() => ProviderContainer(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          automaticBackupSupportedProvider.overrideWithValue(true),
          automaticBackupDesktopProvider.overrideWithValue(false),
        ],
      );
      final first = makeContainer();
      final firstOperation = first.read(automaticBackupProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(await firstOperation.configure('secure-password'), true);
      first.dispose();
      saf.grant = false;
      final restored = makeContainer();
      addTearDown(restored.dispose);
      final operation = restored.read(automaticBackupProvider.notifier);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(
        restored.read(automaticBackupProvider),
        AutomaticBackupStatus.failed,
      );
      await operation.runNow();
      expect(saf.files, isEmpty);
      saf.grant = true;
      await operation.runNow();
      expect(
        restored.read(automaticBackupProvider),
        AutomaticBackupStatus.saved,
      );
      expect(saf.files.length, 1);
      await db.createCategory('After recovery');
      for (var i = 0; i < 100 && saf.files.length < 2; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      expect(saf.files.length, 2);
      for (
        var i = 0;
        i < 50 &&
            restored.read(automaticBackupProvider) ==
                AutomaticBackupStatus.saving;
        i++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
      expect(await db.watchBackupNeeded().first, false);
      await operation.disable();
    },
  );
}
