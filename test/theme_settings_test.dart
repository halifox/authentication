import 'package:authentication/app.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/screens/token_list_screen.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  test(
    'dynamic colors take precedence and black mode changes dark surfaces',
    () {
      final dynamicScheme = ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      );
      expect(
        appColorScheme(Brightness.dark, dynamicScheme, 1, false),
        dynamicScheme,
      );
      final black = appColorScheme(Brightness.dark, dynamicScheme, 1, true);
      expect(black.surface, Colors.black);
      expect(black.surfaceContainer, Colors.black);
      expect(black.primary, dynamicScheme.primary);
      expect(
        appColorScheme(Brightness.light, null, 1, false).primary,
        isNot(appColorScheme(Brightness.light, null, 5, false).primary),
      );
    },
  );
  testWidgets('app follows persisted theme mode and switches palettes', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await db.initializeSettings(defaultSettings);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: const AuthApp(),
      ),
    );
    await tester.pumpAndSettle();
    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app().themeMode, ThemeMode.system);
    await db.setIntegerSetting(themeModeKey, 3);
    await db.setSetting(dynamicColorKey, false);
    await db.setIntegerSetting(accentColorKey, 5);
    await tester.pumpAndSettle();
    expect(app().themeMode, ThemeMode.dark);
    expect(app().darkTheme!.colorScheme.surface, Colors.black);
    expect(
      app().darkTheme!.colorScheme.primary,
      ColorScheme.fromSeed(
        seedColor: Colors.blue,
        brightness: Brightness.dark,
      ).primary,
    );
    await db.setIntegerSetting(themeModeKey, 4);
    await tester.pumpAndSettle();
    expect(app().themeMode, ThemeMode.system);
    expect(app().darkTheme!.colorScheme.surface, Colors.black);
    await db.setIntegerSetting(themeModeKey, 1);
    await tester.pumpAndSettle();
    expect(app().themeMode, ThemeMode.light);
    await db.setIntegerSetting(languageKey, 10);
    await tester.pumpAndSettle();
    expect(app().locale, const Locale('zh'));
    expect(
      AppLocalizations.of(tester.element(find.byType(TokenListScreen)))!
          .settings,
      '设置',
    );
    await db.setIntegerSetting(languageKey, 0);
    await tester.pumpAndSettle();
    expect(app().locale, isNull);
    expect(
      app().localeResolutionCallback!(
        const Locale('zz'),
        app().supportedLocales,
      ),
      const Locale('en'),
    );
    await expectLater(
      db.setIntegerSetting(languageKey, 11),
      throwsFormatException,
    );
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
