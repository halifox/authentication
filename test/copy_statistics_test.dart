import 'dart:convert';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/otp_provider.dart';
import 'package:authentication/otp/token_item_provider.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/settings/settings_provider.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:authentication/widgets/token_list_item.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'copy, advance, reset and backup preserve statistics atomically',
    () async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      await db.initializeSettings(defaultSettings);
      const initial = OtpAccount(
        type: 'hotp',
        issuer: 'Example',
        account: 'user',
        secret: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
        counter: 0,
      );
      await db.addConfig(initial);
      final stored = (await db.getAllConfigs()).single;
      final container = ProviderContainer(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
      );
      addTearDown(container.dispose);
      final listener = container.listen(
        tokenItemProvider(stored.id),
        (_, _) {},
      );
      addTearDown(listener.close);
      final controller = container.read(tokenItemProvider(stored.id).notifier);
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      String? clipboard;
      var fail = false;
      messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
        if (call.method == 'Clipboard.setData') {
          if (fail) throw PlatformException(code: 'failed');
          clipboard = (call.arguments as Map)['text'] as String;
        }
        return null;
      });
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      expect(await controller.copyCode(advanceHotp: true), isTrue);
      expect(clipboard, '755224');
      var current = (await db.getAllConfigs()).single;
      expect(current.counter, 1);
      expect(current.copyCount, 1);
      expect(await controller.copyCode(advanceHotp: false), isTrue);
      current = (await db.getAllConfigs()).single;
      expect(current.counter, 1);
      expect(current.copyCount, 2);
      await db.updateConfig(current.copyWith(copyCount: 0));
      expect((await db.getAllConfigs()).single.copyCount, 2);
      fail = true;
      await expectLater(
        controller.copyCode(advanceHotp: true),
        throwsA(isA<PlatformException>()),
      );
      expect((await db.getAllConfigs()).single.copyCount, 2);
      expect((await db.getAllConfigs()).single.counter, 1);
      fail = false;
      await db.customStatement(
        "CREATE TRIGGER fail_copy BEFORE UPDATE ON auth_entries BEGIN SELECT RAISE(ABORT, 'failure'); END",
      );
      expect(await controller.copyCode(advanceHotp: true), isFalse);
      expect((await db.getAllConfigs()).single.counter, 1);
      expect((await db.getAllConfigs()).single.copyCount, 2);
      await db.customStatement('DROP TRIGGER fail_copy');
      await expectLater(
        db.recordCopy(stored, advanceHotp: true),
        throwsStateError,
      );
      expect((await db.getAllConfigs()).single.counter, 1);

      final backup = await encodeBackupAccounts(
        [current],
        null,
        settings: defaultSettings,
        integerSettings: defaultIntegerSettings,
        includeCopyCounts: true,
      );
      final encrypted = await encodeBackupAccounts(
        [current],
        'password',
        settings: defaultSettings,
        integerSettings: defaultIntegerSettings,
        includeCopyCounts: true,
      );
      expect(
        (await decodeBackupDocument(
          encrypted,
          'password',
        )).accounts.single.copyCount,
        2,
      );
      await expectLater(
        decodeBackupDocument(encrypted, 'wrong'),
        throwsFormatException,
      );
      final document = await decodeBackupDocument(backup, null);
      expect(document.hasCopyCounts, isTrue);
      expect(document.accounts.single.copyCount, 2);
      await controller.resetCopyCount();
      expect((await db.getAllConfigs()).single.copyCount, 0);
      final operations = container.read(backupOperationsProvider.notifier);
      await operations.import(backup, null);
      expect((await db.getAllConfigs()).single.copyCount, 2);
      final legacy = await encodeBackupAccounts(
        [current],
        null,
        settings: defaultSettings,
        integerSettings: defaultIntegerSettings,
      );
      await operations.import(legacy, null);
      expect((await db.getAllConfigs()).single.copyCount, 2);
      final invalid = jsonDecode(utf8.decode(backup)) as Map<String, dynamic>;
      (invalid['entries'] as List).first['copyCount'] = -1;
      await expectLater(
        operations.import(
          Uint8List.fromList(utf8.encode(jsonEncode(invalid))),
          null,
        ),
        throwsFormatException,
      );
      expect((await db.getAllConfigs()).single.copyCount, 2);
    },
  );
  testWidgets(
    'copy count updates on the card and reset asks for confirmation',
    (tester) async {
      FlutterSecureStorage.setMockInitialValues({});
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);
      db.encryption = await EncryptionService.initialize(db);
      await db.initializeSettings({
        ...defaultSettings,
        copyCaptchaOnTapKey: true,
        advanceHotpOnCopyKey: true,
      });
      await db.addConfig(
        const OtpAccount(
          type: 'hotp',
          issuer: 'Example',
          account: 'user',
          secret: 'GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ',
        ),
      );
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (_) async => null,
      );
      addTearDown(
        () => messenger.setMockMethodCallHandler(SystemChannels.platform, null),
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appDatabaseProvider.overrideWithValue(db),
            settingsProvider.overrideWith(
              (ref) => Stream.value({
                ...defaultSettings,
                copyCaptchaOnTapKey: true,
                advanceHotpOnCopyKey: true,
              }),
            ),
          ],
          child: MaterialApp(
            locale: const Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 350,
                  height: 140,
                  child: Consumer(
                    builder: (context, ref, _) {
                      final accounts = ref.watch(authEntryListProvider).value;
                      return accounts == null
                          ? const SizedBox()
                          : TokenListItem(config: accounts.single);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Copies: 0'), findsOneWidget);
      expect(
        ProviderScope.containerOf(tester.element(find.byType(TokenListItem)))
            .read(isCopyCaptchaOnTapProvider),
        isTrue,
      );
      await tester.tap(find.text('Example'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
      expect((await db.getAllConfigs()).single.copyCount, 1);
      expect(find.text('Copies: 1'), findsOneWidget);
      expect((await db.getAllConfigs()).single.counter, 1);
      await tester.drag(find.byType(TokenListItem), const Offset(-320, 0));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reset copy count'));
      await tester.pumpAndSettle();
      expect(find.text('Reset this account’s copy count?'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
      expect((await db.getAllConfigs()).single.copyCount, 0);
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    },
  );
}
