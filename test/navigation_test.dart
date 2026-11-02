import 'package:authentication/router/app_router.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets(
    'named routes return selected values and preserve the back stack',
    (tester) async {
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            navigatorKey: key,
            home: const Scaffold(body: Text('Home')),
            onGenerateRoute: onGenerateRoute,
          ),
        ),
      );
      final selection = key.currentState!.pushNamed<String>(AppRoutes.icons);
      await tester.pumpAndSettle();
      expect(key.currentState!.canPop(), isTrue);
      key.currentState!.pop('assets/icons/github.svg');
      await tester.pumpAndSettle();
      expect(await selection, 'assets/icons/github.svg');
      expect(find.text('Home'), findsOneWidget);
    },
  );
}
