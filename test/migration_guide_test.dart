import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/screens/add_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  testWidgets('guides explain manual steps without importing accounts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
          home: const AddAccountScreen(),
          onGenerateRoute: onGenerateRoute,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Migration guides'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('do not import accounts automatically'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Authy'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Authy'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('does not provide token export'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('Steam'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Steam'));
    await tester.pumpAndSettle();
    expect(find.textContaining('does not export its secret'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Blizzard'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Blizzard'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('does not extract or import its secret'),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
