import 'dart:convert';

import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/migration.dart';
import 'package:authentication/otp/otp_provider.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/screens/add_account_screen.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:protobuf/protobuf.dart';

List<int> parameters(
  String name, {
  int type = 1,
  int algorithm = 1,
  int digits = 1,
  int counter = 0,
}) {
  final writer = CodedBufferWriter();
  writer.writeField(1, PbFieldType.OY, utf8.encode('12345678901234567890'));
  writer.writeField(2, PbFieldType.OS, name);
  writer.writeField(3, PbFieldType.OS, 'Example');
  writer.writeField(4, PbFieldType.O3, algorithm);
  writer.writeField(5, PbFieldType.O3, digits);
  writer.writeField(6, PbFieldType.O3, type);
  writer.writeField(7, PbFieldType.O3, counter);
  return writer.toBuffer();
}

String migrationUri(
  List<List<int>> entries, {
  int batch = 0,
  int size = 1,
  int id = 17,
  int version = 1,
}) {
  final writer = CodedBufferWriter();
  for (final entry in entries) {
    writer.writeField(1, PbFieldType.OY, entry);
  }
  writer.writeField(2, PbFieldType.O3, version);
  writer.writeField(3, PbFieldType.O3, size);
  if (batch != 0) writer.writeField(4, PbFieldType.O3, batch);
  writer.writeField(5, PbFieldType.O3, id);
  return Uri(
    scheme: 'otpauth-migration',
    host: 'offline',
    queryParameters: {'data': base64Encode(writer.toBuffer())},
  ).toString();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('decodes known counter vector and combines out-of-order batches', () {
    final first = parseMigrationUri(
      migrationUri([parameters('Example:alice')], size: 2),
    );
    final second = parseMigrationUri(
      migrationUri(
        [parameters('Example:bob', type: 2, algorithm: 2, digits: 2)],
        batch: 1,
        size: 2,
      ),
    );
    expect(first.accounts.single.account, 'alice');
    expect(first.accounts.single.generateCodeString(), '755224');
    expect(second.accounts.single.algorithm, 'sha256');
    expect(second.accounts.single.digits, 8);
    final collector = MigrationCollector()..add(second);
    expect(collector.complete, isFalse);
    expect(() => collector.finish(), throwsFormatException);
    collector.add(first);
    expect(collector.finish().map((e) => e.account), ['alice', 'bob']);
    expect(() => collector.add(first), throwsFormatException);
  });
  test('rejects unsupported, malformed, mismatched and duplicate data', () {
    expect(
      () => parseMigrationUri(
        migrationUri([parameters('Example:a', algorithm: 4)]),
      ),
      throwsFormatException,
    );
    expect(
      () => parseMigrationUri(
        migrationUri([parameters('Example:a')], version: 2),
      ),
      throwsFormatException,
    );
    expect(
      () => parseMigrationUri('otpauth-migration://offline?data=%%%'),
      throwsFormatException,
    );
    final truncated = Uri(
      scheme: 'otpauth-migration',
      host: 'offline',
      queryParameters: {
        'data': base64Encode([10, 128]),
      },
    ).toString();
    expect(() => parseMigrationUri(truncated), throwsFormatException);
    expect(
      () => parseMigrationUri(
        migrationUri([parameters('Example:a')], batch: 2, size: 2),
      ),
      throwsFormatException,
    );
    final collector = MigrationCollector()
      ..add(
        parseMigrationUri(migrationUri([parameters('Example:a')], size: 2)),
      );
    expect(
      () => collector.add(
        parseMigrationUri(
          migrationUri([parameters('Example:b')], batch: 1, size: 2, id: 18),
        ),
      ),
      throwsFormatException,
    );
    collector.add(
      parseMigrationUri(
        migrationUri([parameters('Example:a')], batch: 1, size: 2),
      ),
    );
    expect(() => collector.finish(), throwsFormatException);
  });
  test(
    'batch import preserves metadata and rolls back on write failure',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      final batch = parseMigrationUri(
        migrationUri([
          parameters('Example:alice'),
          parameters('Example:bob', type: 2),
        ]),
      );
      final old = batch.accounts.first.copyWith(
        secret: 'JBSWY3DPEHPK3PXP',
        icon: 'assets/icons/github.svg',
        sortOrder: 9,
        createdAt: 123,
        copyCount: 7,
      );
      await db.addConfig(old, preserveSortOrder: true);
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      final operations = container.read(accountOperationsProvider.notifier);
      await db.customStatement(
        "CREATE TRIGGER reject_insert BEFORE INSERT ON auth_entries BEGIN SELECT RAISE(ABORT, 'failure'); END",
      );
      await expectLater(
        operations.importMigration(batch.accounts),
        throwsA(anything),
      );
      final unchanged = (await db.getAllConfigs()).single;
      expect(unchanged.secret, old.secret);
      expect(unchanged.copyCount, 7);
      await db.customStatement('DROP TRIGGER reject_insert');
      expect(await operations.importMigration(batch.accounts), 2);
      final updated = (await db.getAllConfigs()).firstWhere(
        (e) => e.account == 'alice',
      );
      expect(updated.secret, batch.accounts.first.secret);
      expect(updated.icon, old.icon);
      expect(updated.createdAt, old.createdAt);
      expect(updated.sortOrder, old.sortOrder);
      expect(updated.copyCount, old.copyCount);
      expect(
        (await db.getAllConfigs())
            .firstWhere((e) => e.account == 'bob')
            .createdAt,
        greaterThan(0),
      );
      expect(
        (await db.getAllAuthEntries()).every(
          (e) => e.secret.startsWith('enc:v1:'),
        ),
        isTrue,
      );
    },
  );
  test(
    'distinct issuer and account pairs cannot collide at delimiter characters',
    () {
      final account = parseMigrationUri(migrationUri([parameters('Example:a')]))
          .accounts
          .single;
      final collector = MigrationCollector()
        ..add(
          MigrationBatch(
            id: 1,
            size: 1,
            index: 0,
            accounts: [
              account.copyWith(issuer: 'A\u0000B', account: 'C'),
              account.copyWith(issuer: 'A', account: 'B\u0000C'),
            ],
          ),
        );
      expect(collector.finish().length, 2);
    },
  );
  testWidgets('multiple codes import only after all batches and confirmation', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    final codes = [
      migrationUri([parameters('Example:alice')], size: 2),
      migrationUri([parameters('Example:bob', type: 2)], batch: 1, size: 2),
    ];
    var next = 0;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appDatabaseProvider.overrideWithValue(db),
          qrPlatformSupportedProvider.overrideWithValue(true),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => const AddAccountScreen(),
                  ),
                ),
                child: const Text('Open'),
              ),
            ),
          ),
          onGenerateRoute: (settings) => settings.name == AppRoutes.scan
              ? MaterialPageRoute<BarcodeCapture>(
                  builder: (context) => Scaffold(
                    body: TextButton(
                      onPressed: () => Navigator.pop(
                        context,
                        BarcodeCapture(
                          barcodes: [Barcode(rawValue: codes[next++])],
                        ),
                      ),
                      child: const Text('Simulate scan'),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Scan QR Code'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simulate scan'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Received 1 of 2 codes'), findsOneWidget);
    expect(await db.getAllConfigs(), isEmpty);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(await db.getAllConfigs(), isEmpty);
    next = 0;
    await tester.tap(find.text('Scan QR Code'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simulate scan'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Received 1 of 2 codes'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Simulate scan'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Import 2 accounts?'), findsOneWidget);
    expect(
      find.textContaining('New accounts: 2. Existing accounts to update: 0.'),
      findsOneWidget,
    );
    expect(await db.getAllConfigs(), isEmpty);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Imported 2 accounts.'), findsOneWidget);
    expect((await db.getAllConfigs()).length, 2);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
