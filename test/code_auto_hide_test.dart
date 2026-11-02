import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/token_item_provider.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/settings/settings_provider.dart';
import 'package:authentication/widgets/token_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets(
    'revealed code hides after the selected duration and timers cancel',
    (tester) async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final provider = tokenItemProvider(1);
      final listener = container.listen(provider, (_, _) {});
      addTearDown(listener.close);
      final token = container.read(provider.notifier);
      token.toggleReveal(5);
      expect(container.read(provider).isRevealed, isTrue);
      await tester.pump(const Duration(seconds: 4));
      expect(container.read(provider).isRevealed, isTrue);
      token.toggleReveal(5);
      expect(container.read(provider).isRevealed, isFalse);
      token.toggleReveal(10);
      await tester.pump(const Duration(seconds: 5));
      expect(container.read(provider).isRevealed, isTrue);
      await tester.pump(const Duration(seconds: 5));
      expect(container.read(provider).isRevealed, isFalse);
      token.toggleReveal(0);
      await tester.pump(const Duration(seconds: 60));
      expect(container.read(provider).isRevealed, isTrue);
      token.toggleReveal(5);
      token.toggleReveal(5);
      listener.close();
      container.dispose();
      await tester.pump(const Duration(seconds: 5));
    },
  );
  testWidgets('account card reveals and automatically hides its code', (
    tester,
  ) async {
    const account = OtpAccount(
      id: 1,
      type: 'hotp',
      issuer: 'Example',
      account: 'user',
      secret: 'JBSWY3DPEHPK3PXP',
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsProvider.overrideWith(
            (ref) =>
                Stream.value({...defaultSettings, showCaptchaOnTapKey: true}),
          ),
          integerSettingsProvider.overrideWith(
            (ref) => Stream.value({hideCodeAfterKey: 5}),
          ),
        ],
        child: const MaterialApp(
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
    await tester.pumpAndSettle();
    expect(find.text('-'), findsNWidgets(6));
    await tester.tap(find.byType(TokenListItem));
    await tester.pump();
    expect(find.text('-'), findsNothing);
    await tester.pump(const Duration(seconds: 5));
    expect(find.text('-'), findsNWidgets(6));
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
