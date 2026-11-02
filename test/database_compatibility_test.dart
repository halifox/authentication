import 'package:authentication/settings/settings.dart';
import 'package:authentication/storage/database.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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
