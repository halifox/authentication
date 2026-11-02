import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:authentication/backup/html_backup.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/screens/add_account_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  const account = OtpAccount(
    type: 'totp',
    issuer: '<script>alert(1)</script>',
    account: 'alice@example.test',
    secret: 'JBSWY3DPEHPK3PXP',
  );
  test('escapes account text and rejects any unsupported account', () {
    final html = utf8.decode(
      encodeHtmlBackup([account], title: 'Backup', warning: 'Unencrypted'),
    );
    expect(html.contains('&lt;script&gt;alert(1)&lt;&#47;script&gt;'), isTrue);
    expect(html.contains('<script>'), isFalse);
    final uri = Uri.parse(toStandardOtpQrUri(account));
    expect(uri.pathSegments, ['${account.issuer}:${account.account}']);
    final two = utf8.decode(
      encodeHtmlBackup(
        [account, account.copyWith(account: 'bob')],
        title: 'Backup',
        warning: 'Unencrypted',
      ),
    );
    expect(RegExp('<svg ').allMatches(two).length, 2);
    expect(html.contains('Unencrypted'), isTrue);
    expect(html.contains('<svg'), isTrue);
    expect(html.contains('JBSWY3DPEHPK3PXP'), isFalse);
    expect(
      () => encodeHtmlBackup([], title: 'Backup', warning: 'Unencrypted'),
      throwsFormatException,
    );
    expect(
      () => encodeHtmlBackup(
        [account, account.copyWith(type: 'hotp', digits: 7)],
        title: 'Backup',
        warning: 'Unencrypted',
      ),
      throwsFormatException,
    );
  });
  testWidgets('generated SVG renders a scannable symbol', (tester) async {
    final html = utf8.decode(
      encodeHtmlBackup([account], title: 'Backup', warning: 'Unencrypted'),
    );
    final svg = RegExp(
      r'<svg\b.*?</svg>',
      dotAll: true,
    ).firstMatch(html)!.group(0)!;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: RepaintBoundary(
              key: const ValueKey('html_qr'),
              child: SizedBox(
                width: 320,
                height: 320,
                child: SvgPicture.string(svg),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('html_qr')), findsOneWidget);
    final output = Platform.environment['QR_HTML_TEST_OUTPUT'];
    if (output != null) {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('html_qr')),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File(output).writeAsBytes(bytes!.buffer.asUint8List());
        await File('$output.uri').writeAsString(toStandardOtpQrUri(account));
        image.dispose();
      });
    }
  });
  testWidgets('HTML export warns before opening a save dialog', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AddAccountScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Export HTML backup'),
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.tap(find.text('Export HTML backup'));
    await tester.pumpAndSettle();
    expect(find.textContaining('unencrypted HTML file'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.textContaining('unencrypted HTML file'), findsNothing);
  });
}
