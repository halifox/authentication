import 'dart:async';

import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/category_provider.dart';
import 'package:authentication/otp/otp_provider.dart';
import 'package:authentication/screens/token_list_screen.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/settings/settings_provider.dart';
import 'package:authentication/widgets/token_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('search filters issuer and account and follows list changes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final entries = StreamController<List<OtpAccount>>.broadcast();
    addTearDown(entries.close);
    final settings = StreamController<Map<String, bool>>.broadcast();
    addTearDown(settings.close);
    const alice = OtpAccount(
      id: 1,
      type: 'hotp',
      issuer: 'Example',
      account: 'Alice',
      secret: 'JBSWY3DPEHPK3PXP',
    );
    const bob = OtpAccount(
      id: 2,
      type: 'hotp',
      issuer: 'Another',
      account: 'Bob',
      secret: 'JBSWY3DPEHPK3PXP',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authEntryListProvider.overrideWith((ref) => entries.stream),
          backupNeededProvider.overrideWith((ref) => Stream.value(false)),
          settingsProvider.overrideWith((ref) => settings.stream),
          categoriesProvider.overrideWith((ref) => Stream.value([])),
          categoryMembershipsProvider.overrideWith((ref) => Stream.value({})),
          integerSettingsProvider.overrideWith(
            (ref) => Stream.value(defaultIntegerSettings),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TokenListScreen(),
        ),
      ),
    );
    entries.add([alice, bob]);
    settings.add({showAccountNameKey: true});
    await tester.pumpAndSettle();
    expect(find.byType(TokenListItem), findsNWidgets(2));

    await tester.enterText(find.byType(TextField), '  EXAMPLE  ');
    await tester.pump();
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);

    await tester.enterText(find.byType(TextField), 'bOb');
    await tester.pump();
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Alice'), findsNothing);
    settings.add({showAccountNameKey: false});
    await tester.pump();
    expect(find.text('Bob'), findsNothing);
    expect(find.text('Another'), findsOneWidget);
    settings.add({showAccountNameKey: true});
    await tester.pump();

    entries.add([alice]);
    await tester.pump();
    expect(find.text('No matching accounts'), findsOneWidget);
    await tester.tap(find.byTooltip('Clear search'));
    await tester.pump();
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('No matching accounts'), findsNothing);

    entries.add([]);
    await tester.pump();
    expect(find.text('No data'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
  });
}
