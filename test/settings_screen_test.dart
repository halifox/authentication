import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/screens/settings_screen.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('usage guide is accessible from settings at large text sizes', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.initializeSettings(defaultSettings);
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: onGenerateRoute,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const SettingsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Using the app'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Using the app'));
    await tester.pumpAndSettle();
    expect(find.text('Add an account'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Move existing accounts'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('conflict policy'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });

  testWidgets('settings changes persist and database changes update the UI', (
    tester,
  ) async {
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    await db.initializeSettings(defaultSettings);
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
    final revealSwitch = find.ancestor(
      of: find.text('Tap to Reveal Code'),
      matching: find.byType(SettingsSwitchTile),
    );
    expect(
      find.descendant(of: revealSwitch, matching: find.byIcon(Icons.close)),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(of: revealSwitch, matching: find.byIcon(Icons.close)),
    );
    await tester.pumpAndSettle();
    expect((await db.getSettings())[showCaptchaOnTapKey], isTrue);
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('Tap to Reveal Code'),
          matching: find.byType(SettingsSwitchTile),
        ),
        matching: find.byIcon(Icons.done),
      ),
      findsOneWidget,
    );
    await db.setSetting(copyCaptchaOnTapKey, true);
    await tester.pumpAndSettle();
    expect(
      find.descendant(
        of: find.ancestor(
          of: find.text('Tap to Copy Code'),
          matching: find.byType(SettingsSwitchTile),
        ),
        matching: find.byIcon(Icons.done),
      ),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(
        of: find.ancestor(
          of: find.text('Show account name'),
          matching: find.byType(SettingsSwitchTile),
        ),
        matching: find.byIcon(Icons.done),
      ),
    );
    await tester.pumpAndSettle();
    expect((await db.getSettings())[showAccountNameKey], isFalse);
    await tester.scrollUntilVisible(
      find.text('Use system font for codes'),
      150,
      scrollable: find.byType(Scrollable),
    );
    final fontSwitch = find.ancestor(
      of: find.text('Use system font for codes'),
      matching: find.byType(SettingsSwitchTile),
    );
    await tester.tap(
      find.descendant(of: fontSwitch, matching: find.byIcon(Icons.close)),
    );
    await tester.pumpAndSettle();
    expect((await db.getSettings())[systemCodeFontKey], isTrue);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey(hideCodeAfterKey)),
      150,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.byKey(const ValueKey(hideCodeAfterKey)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10 seconds').last);
    await tester.pumpAndSettle();
    expect((await db.getIntegerSettings())[hideCodeAfterKey], 10);
    await tester.drag(find.byType(GridView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey(codeGroupingKey)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Every 3 characters').last);
    await tester.pumpAndSettle();
    expect((await db.getIntegerSettings())[codeGroupingKey], 3);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey(themeModeKey)),
      150,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.byKey(const ValueKey(themeModeKey)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Black').last);
    await tester.pumpAndSettle();
    expect((await db.getIntegerSettings())[themeModeKey], 3);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey(accentColorKey)),
      150,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.byKey(const ValueKey(accentColorKey)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Blue').last);
    await tester.pumpAndSettle();
    expect((await db.getIntegerSettings())[accentColorKey], 5);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey(languageKey)),
      150,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.byKey(const ValueKey(languageKey)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('日本語').last);
    await tester.pumpAndSettle();
    expect((await db.getIntegerSettings())[languageKey], 6);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
