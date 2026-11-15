import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/screens/qr_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

void main() {
  testWidgets(
    'covered scanner ignores detections and cancel returns no result',
    (tester) async {
      final key = GlobalKey<NavigatorState>();
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: key,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: Text('Origin')),
        ),
      );
      final result = key.currentState!.push<BarcodeCapture>(
        MaterialPageRoute(builder: (_) => const QrScannerScreen()),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));
      final detect = tester
          .widget<MobileScanner>(find.byType(MobileScanner))
          .onDetect!;
      key.currentState!.push<void>(
        MaterialPageRoute(builder: (_) => const Scaffold(body: Text('Cover'))),
      );
      await tester.pumpAndSettle();
      detect(const BarcodeCapture(barcodes: [Barcode(rawValue: 'code')]));
      await tester.pumpAndSettle();
      expect(find.text('Cover'), findsOneWidget);
      key.currentState!.pop();
      await tester.pumpAndSettle();
      key.currentState!.pop();
      await tester.pumpAndSettle();
      expect(await result, isNull);
      expect(find.text('Origin'), findsOneWidget);
    },
  );
}
