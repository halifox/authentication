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
    final query = ValueNotifier('');
    addTearDown(query.dispose);
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
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ValueListenableBuilder(
            valueListenable: query,
            builder: (context, value, _) => TokenListScreen(searchQuery: value),
          ),
        ),
      ),
    );
    entries.add([alice, bob]);
    settings.add({showAccountNameKey: true});
    await tester.pumpAndSettle();
    expect(find.byType(TokenListItem), findsNWidgets(2));

    query.value = '  EXAMPLE  ';
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('Bob'), findsNothing);

    query.value = 'bOb';
    await tester.pumpAndSettle();
    expect(find.text('Bob'), findsOneWidget);
    expect(find.text('Alice'), findsNothing);
    settings.add({showAccountNameKey: false});
    await tester.pumpAndSettle();
    expect(find.text('Bob'), findsNothing);
    expect(find.text('Another'), findsOneWidget);
    settings.add({showAccountNameKey: true});
    await tester.pumpAndSettle();

    entries.add([alice]);
    await tester.pumpAndSettle();
    expect(find.text('No matching accounts'), findsOneWidget);
    query.value = '';
    await tester.pumpAndSettle();
    expect(find.text('Alice'), findsOneWidget);
    expect(find.text('No matching accounts'), findsNothing);

    entries.add([]);
    await tester.pumpAndSettle();
    expect(find.text('No data'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
