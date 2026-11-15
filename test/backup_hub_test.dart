import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/screens/add_account_screen.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('backup hub opens import and export pages and returns', (
    tester,
  ) async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          onGenerateRoute: onGenerateRoute,
          home: AddAccountScreen(page: AccountActionPage.backupHub),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Export app backup'), findsOneWidget);
    expect(find.text('Restore app backup'), findsOneWidget);
    await tester.tap(find.text('Import other formats'));
    await tester.pumpAndSettle();
    expect(find.text('Import URI list'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.text('All export formats'));
    await tester.pumpAndSettle();
    expect(find.text('Export HTML backup'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Restore app backup'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
  testWidgets('import labels wrap at large text sizes', (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(database)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: const AddAccountScreen(page: AccountActionPage.importFile),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final label = find.text('Import TOTP Authenticator backup');
    await tester.scrollUntilVisible(
      label,
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(label);
    await tester.pumpAndSettle();
    expect(
      tester.renderObject<RenderParagraph>(label).didExceedMaxLines,
      isFalse,
    );
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
