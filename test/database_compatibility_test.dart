import 'package:authentication/settings/settings.dart';
import 'package:authentication/storage/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'upgrades version 6 and preserves accounts and backup tracking',
    () async {
      final database = AppDatabase(
        NativeDatabase.memory(
          setup: (sqlite) {
            sqlite.execute(
              'CREATE TABLE backup_state (id INTEGER PRIMARY KEY NOT NULL, revision INTEGER NOT NULL, saved_revision INTEGER NOT NULL)',
            );
            sqlite.execute('INSERT INTO backup_state VALUES (1, 3, 2)');
            sqlite.execute(
              'CREATE TABLE app_settings (key TEXT NOT NULL PRIMARY KEY, value INTEGER NOT NULL)',
            );
            sqlite.execute(
              'CREATE TABLE app_integer_settings (key TEXT NOT NULL PRIMARY KEY, value INTEGER NOT NULL)',
            );
            sqlite.execute(
              'CREATE TABLE categories (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE, sort_order INTEGER NOT NULL, is_default INTEGER NOT NULL DEFAULT 0)',
            );
            sqlite.execute(
              'CREATE TABLE account_category_links (account_id INTEGER NOT NULL, category_id INTEGER NOT NULL, PRIMARY KEY (account_id, category_id))',
            );
            sqlite.execute(
              'CREATE TABLE auth_entries (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, scheme TEXT NOT NULL, type TEXT NOT NULL, issuer TEXT NOT NULL, account TEXT NOT NULL, secret TEXT NOT NULL, algorithm TEXT NOT NULL, digits INTEGER NOT NULL, period INTEGER NOT NULL, counter INTEGER NOT NULL, pin TEXT NOT NULL, icon TEXT NOT NULL, sort_order INTEGER NOT NULL, created_at INTEGER NOT NULL, copy_count INTEGER NOT NULL DEFAULT 0, UNIQUE (issuer, account))',
            );
            sqlite.execute(
              "INSERT INTO auth_entries VALUES (1, 'otpauth', 'totp', 'Example', 'user', 'secret', 'sha1', 6, 30, 0, '', 'assets/icons/passkey.svg', 0, 1, 7)",
            );
            sqlite.execute('PRAGMA user_version = 6');
          },
        ),
      );
      addTearDown(database.close);
      expect((await database.getAllAuthEntries()).single.copyCount, 7);
      expect(await database.getIconPacks(), isEmpty);
      expect(await database.backupRevision(), 3);
      expect(await database.watchBackupNeeded().first, isTrue);
    },
  );
  test('upgrades version 5 and preserves category links', () async {
    final database = AppDatabase(
      NativeDatabase.memory(
        setup: (sqlite) {
          sqlite.execute(
            'CREATE TABLE app_settings (key TEXT NOT NULL PRIMARY KEY, value INTEGER NOT NULL)',
          );
          sqlite.execute(
            'CREATE TABLE app_integer_settings (key TEXT NOT NULL PRIMARY KEY, value INTEGER NOT NULL)',
          );
          sqlite.execute(
            'CREATE TABLE auth_entries (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, scheme TEXT NOT NULL, type TEXT NOT NULL, issuer TEXT NOT NULL, account TEXT NOT NULL, secret TEXT NOT NULL, algorithm TEXT NOT NULL, digits INTEGER NOT NULL, period INTEGER NOT NULL, counter INTEGER NOT NULL, pin TEXT NOT NULL, icon TEXT NOT NULL, sort_order INTEGER NOT NULL, created_at INTEGER NOT NULL, copy_count INTEGER NOT NULL DEFAULT 0, UNIQUE (issuer, account))',
          );
          sqlite.execute(
            "INSERT INTO auth_entries VALUES (1, 'otpauth', 'totp', 'Example', 'user', 'secret', 'sha1', 6, 30, 0, '', '', 0, 1, 7)",
          );
          sqlite.execute(
            'CREATE TABLE categories (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE, sort_order INTEGER NOT NULL, is_default INTEGER NOT NULL DEFAULT 0)',
          );
          sqlite.execute("INSERT INTO categories VALUES (1, 'Work', 0, 1)");
          sqlite.execute(
            'CREATE TABLE account_category_links (account_id INTEGER NOT NULL, category_id INTEGER NOT NULL, PRIMARY KEY (account_id, category_id))',
          );
          sqlite.execute('INSERT INTO account_category_links VALUES (1, 1)');
          sqlite.execute('PRAGMA user_version = 5');
        },
      ),
    );
    addTearDown(database.close);
    expect((await database.getAllAuthEntries()).single.secret, 'secret');
    expect((await database.getCategories()).single.name, 'Work');
    expect(await database.getCategoryMemberships(), {
      1: {1},
    });
    expect(await database.watchBackupNeeded().first, true);
  });
  test(
    'upgrades version 4 without losing accounts, statistics or settings',
    () async {
      final database = AppDatabase(
        NativeDatabase.memory(
          setup: (sqlite) {
            sqlite.execute(
              'CREATE TABLE app_settings (key TEXT NOT NULL PRIMARY KEY, value INTEGER NOT NULL)',
            );
            sqlite.execute(
              "INSERT INTO app_settings VALUES ('is_show_captcha_on_tap', 1)",
            );
            sqlite.execute(
              'CREATE TABLE app_integer_settings (key TEXT NOT NULL PRIMARY KEY, value INTEGER NOT NULL)',
            );
            sqlite.execute(
              "INSERT INTO app_integer_settings VALUES ('hide_code_after_seconds', 10)",
            );
            sqlite.execute(
              'CREATE TABLE auth_entries (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, scheme TEXT NOT NULL, type TEXT NOT NULL, issuer TEXT NOT NULL, account TEXT NOT NULL, secret TEXT NOT NULL, algorithm TEXT NOT NULL, digits INTEGER NOT NULL, period INTEGER NOT NULL, counter INTEGER NOT NULL, pin TEXT NOT NULL, icon TEXT NOT NULL, sort_order INTEGER NOT NULL, created_at INTEGER NOT NULL, copy_count INTEGER NOT NULL DEFAULT 0, UNIQUE (issuer, account))',
            );
            sqlite.execute(
              "INSERT INTO auth_entries VALUES (1, 'otpauth', 'totp', 'Example', 'user', 'secret', 'sha1', 6, 30, 0, '', '', 0, 1, 7)",
            );
            sqlite.execute('PRAGMA user_version = 4');
          },
        ),
      );
      addTearDown(database.close);
      final entry = (await database.getAllAuthEntries()).single;
      expect(entry.secret, 'secret');
      expect(entry.copyCount, 7);
      expect((await database.getSettings())[showCaptchaOnTapKey], isTrue);
      expect((await database.getIntegerSettings())[hideCodeAfterKey], 10);
      expect(await database.getCategories(), isEmpty);
      expect(await database.getCategoryMemberships(), isEmpty);
    },
  );
  test('opens an existing version 1 database without losing entries', () async {
    final database = AppDatabase(
      NativeDatabase.memory(
        setup: (sqlite) {
          sqlite.execute('''
            CREATE TABLE auth_entries (
              id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
              scheme TEXT NOT NULL, type TEXT NOT NULL, issuer TEXT NOT NULL,
              account TEXT NOT NULL, secret TEXT NOT NULL, algorithm TEXT NOT NULL,
              digits INTEGER NOT NULL, period INTEGER NOT NULL, counter INTEGER NOT NULL,
              pin TEXT NOT NULL, icon TEXT NOT NULL, sort_order INTEGER NOT NULL,
              created_at INTEGER NOT NULL, UNIQUE (issuer, account)
            )
          ''');
          sqlite.execute(
            "INSERT INTO auth_entries VALUES (1, 'otpauth', 'totp', 'Example', 'user', 'secret', 'SHA1', 6, 30, 0, '', '', 0, 1)",
          );
          sqlite.execute('PRAGMA user_version = 1');
        },
      ),
    );
    addTearDown(database.close);

    final entries = await database.getAllAuthEntries();
    expect(entries.single.issuer, 'Example');
    expect(entries.single.secret, 'secret');
    expect(entries.single.period, 30);
    expect(entries.single.copyCount, 0);
    expect(await database.getCategories(), isEmpty);
    expect(await database.getCategoryMemberships(), isEmpty);
    expect(await database.getIntegerSettings(), defaultIntegerSettings);
    await database.setIntegerSetting(hideCodeAfterKey, 10);
    expect((await database.getIntegerSettings())[hideCodeAfterKey], 10);
    await database.initializeSettings({
      showCaptchaOnTapKey: true,
      copyCaptchaOnTapKey: false,
    });
    expect(await database.getSettings(), {
      showCaptchaOnTapKey: true,
      copyCaptchaOnTapKey: false,
      showAccountNameKey: true,
      advanceHotpOnCopyKey: false,
      sortLockedKey: true,
      dynamicColorKey: true,
      backupRemindersKey: true,
      systemCodeFontKey: false,
      screenProtectionKey: true,
    });
    await database.setSetting(showCaptchaOnTapKey, false);
    await database.initializeSettings({
      showCaptchaOnTapKey: true,
      copyCaptchaOnTapKey: true,
    });
    expect(await database.getSettings(), {
      showCaptchaOnTapKey: false,
      copyCaptchaOnTapKey: false,
      showAccountNameKey: true,
      advanceHotpOnCopyKey: false,
      sortLockedKey: true,
      dynamicColorKey: true,
      backupRemindersKey: true,
      systemCodeFontKey: false,
      screenProtectionKey: true,
    });
    expect((await database.getAllAuthEntries()).single.secret, 'secret');
  });
  test('upgrades version 2 and retains accounts and settings', () async {
    final database = AppDatabase(
      NativeDatabase.memory(
        setup: (sqlite) {
          sqlite.execute(
            'CREATE TABLE app_settings (key TEXT NOT NULL PRIMARY KEY, value INTEGER NOT NULL CHECK (value IN (0, 1)))',
          );
          sqlite.execute(
            "INSERT INTO app_settings VALUES ('is_show_captcha_on_tap', 1)",
          );
          sqlite.execute(
            'CREATE TABLE auth_entries (id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, scheme TEXT NOT NULL, type TEXT NOT NULL, issuer TEXT NOT NULL, account TEXT NOT NULL, secret TEXT NOT NULL, algorithm TEXT NOT NULL, digits INTEGER NOT NULL, period INTEGER NOT NULL, counter INTEGER NOT NULL, pin TEXT NOT NULL, icon TEXT NOT NULL, sort_order INTEGER NOT NULL, created_at INTEGER NOT NULL, UNIQUE (issuer, account))',
          );
          sqlite.execute(
            "INSERT INTO auth_entries VALUES (1, 'otpauth', 'totp', 'Example', 'user', 'secret', 'sha1', 6, 30, 0, '', '', 0, 1)",
          );
          sqlite.execute('PRAGMA user_version = 2');
        },
      ),
    );
    addTearDown(database.close);
    expect((await database.getAllAuthEntries()).single.secret, 'secret');
    expect((await database.getSettings())[showCaptchaOnTapKey], isTrue);
    expect(await database.getIntegerSettings(), defaultIntegerSettings);
    await database.setIntegerSetting(hideCodeAfterKey, 30);
    expect((await database.getIntegerSettings())[hideCodeAfterKey], 30);
  });
}
