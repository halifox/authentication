import 'dart:async';

import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/otp.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/settings/settings_provider.dart';
import 'package:authentication/widgets/token_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  test('groups fixed widths, halves and thirds for different code lengths', () {
    expect(codeGroupBreaks(6, 0), isEmpty);
    expect(codeGroupBreaks(8, 2), [2, 4, 6]);
    expect(codeGroupBreaks(8, 3), [3, 6]);
    expect(codeGroupBreaks(8, 4), [4]);
    expect(codeGroupBreaks(5, 5), [3]);
    expect(codeGroupBreaks(8, 6), [3, 6]);
    expect(codeGroupBreaks(5, 6), [2, 4]);
    expect(() => codeGroupBreaks(6, 7), throwsArgumentError);
  });
  testWidgets('ten-digit account remains visible on a narrow screen', (
    tester,
  ) async {
    const account = OtpAccount(
      id: 1,
      type: 'totp',
      issuer: 'Example',
      account: 'user',
      secret: 'JBSWY3DPEHPK3PXP',
      digits: 10,
    );
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 280,
              height: 150,
              child: TokenListItem(config: account),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.text('-'), findsNWidgets(10));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
  testWidgets(
    'account card changes group spacing without exposing hidden code',
    (tester) async {
      final settings = StreamController<Map<String, int>>.broadcast();
      addTearDown(settings.close);
      final booleanSettings = StreamController<Map<String, bool>>.broadcast();
      addTearDown(booleanSettings.close);
      const account = OtpAccount(
        id: 1,
        type: 'hotp',
        issuer: 'Example',
        account: 'user',
        secret: 'JBSWY3DPEHPK3PXP',
        digits: 8,
      );
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            settingsProvider.overrideWith((ref) => booleanSettings.stream),
            integerSettingsProvider.overrideWith((ref) => settings.stream),
          ],
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 350,
                  height: 140,
                  child: TokenListItem(config: account),
                ),
              ),
            ),
          ),
        ),
      );
      settings.add({...defaultIntegerSettings, codeGroupingKey: 3});
      booleanSettings.add({...defaultSettings, showCaptchaOnTapKey: true});
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('group_3')), findsOneWidget);
      expect(find.byKey(const ValueKey('group_6')), findsOneWidget);
      expect(find.bySemanticsLabel(RegExp('Code hidden')), findsOneWidget);
      expect(find.text('-'), findsNWidgets(8));
      expect(
        tester.widget<Text>(find.text('-').first).style!.fontFamily,
        'VarelaRound',
      );
      booleanSettings.add({
        ...defaultSettings,
        showCaptchaOnTapKey: true,
        systemCodeFontKey: true,
      });
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.text('-').first).style!.fontFamily,
        isNull,
      );
      settings.add({...defaultIntegerSettings, codeGroupingKey: 5});
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('group_4')), findsOneWidget);
      expect(find.byKey(const ValueKey('group_3')), findsNothing);
      semantics.dispose();
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(milliseconds: 10));
    },
  );
}
