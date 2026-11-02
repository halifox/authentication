import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/screens/settings_screen.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
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
    expect(find.byIcon(Icons.close), findsNWidgets(2));
    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pumpAndSettle();
    expect((await db.getSettings())[showCaptchaOnTapKey], isTrue);
    expect(find.byIcon(Icons.done), findsNWidgets(2));
    await db.setSetting(copyCaptchaOnTapKey, true);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.done), findsNWidgets(3));
    await tester.tap(find.byIcon(Icons.done).last);
    await tester.pumpAndSettle();
    expect((await db.getSettings())[showAccountNameKey], isFalse);
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('10 seconds').last);
    await tester.pumpAndSettle();
    expect((await db.getIntegerSettings())[hideCodeAfterKey], 10);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
