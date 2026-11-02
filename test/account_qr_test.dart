import 'dart:io';
import 'dart:ui' as ui;

import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/screens/token_form_screen.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:authentication/widgets/account_qr.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const account = OtpAccount(
    type: 'totp',
    issuer: '示例',
    account: 'alice@example.test',
    secret: 'JBSWY3DPEHPK3PXP',
    algorithm: 'sha256',
    digits: 8,
    period: 45,
  );
  testWidgets('renders a standard QR image with a quiet zone', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 320,
              child: AccountQr(account: account),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('account_qr')), findsOneWidget);
    expect(
      find.bySemanticsLabel('QR code containing an account secret'),
      findsOneWidget,
    );
    final output = Platform.environment['QR_TEST_OUTPUT'];
    if (output != null) {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('account_qr')),
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
  test(
    'standard QR URI uses compatible parameters and rejects ambiguous labels',
    () {
      final uri = Uri.parse(toStandardOtpQrUri(account));
      expect(uri.scheme, 'otpauth');
      expect(uri.host, 'totp');
      expect(uri.queryParameters['algorithm'], 'SHA256');
      expect(uri.queryParameters['digits'], '8');
      expect(uri.queryParameters['period'], '45');
      final hotp = account.copyWith(type: 'hotp', counter: 42, digits: 6);
      expect(
        Uri.parse(toStandardOtpQrUri(hotp)).queryParameters['counter'],
        '42',
      );
      expect(
        () => toStandardOtpQrUri(account.copyWith(digits: 7)),
        throwsFormatException,
      );
      expect(
        () => toStandardOtpQrUri(account.copyWith(issuer: 'A:B')),
        throwsFormatException,
      );
    },
  );
  testWidgets('renders a counter-based QR image', (tester) async {
    final hotp = account.copyWith(type: 'hotp', counter: 42, digits: 6);
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 320,
              height: 320,
              child: AccountQr(account: hotp),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('account_qr')), findsOneWidget);
    final output = Platform.environment['QR_TEST_OUTPUT'];
    if (output != null) {
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const ValueKey('account_qr')),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 1);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        await File('$output.hotp.png')
            .writeAsBytes(bytes!.buffer.asUint8List());
        await File('$output.hotp.png.uri')
            .writeAsString(toStandardOtpQrUri(hotp));
        image.dispose();
      });
    }
  });
  testWidgets('unsupported and oversized accounts show an explicit error', (
    tester,
  ) async {
    const unsupported = OtpAccount(
      type: 'motp',
      issuer: 'Example',
      account: 'user',
      secret: 'abc',
      pin: '1234',
    );
    Future<void> show(OtpAccount value) async {
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 200,
              child: AccountQr(account: value),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    await show(unsupported);
    expect(
      find.text(
        'QR export is available only for time-based and counter-based accounts.',
      ),
      findsOneWidget,
    );
    await show(account.copyWith(account: 'x' * 3000));
    expect(
      find.text('The QR code cannot be displayed at a scannable size.'),
      findsOneWidget,
    );
  });
  testWidgets('saved account requires confirmation before displaying its QR', (
    tester,
  ) async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    await db.addConfig(account);
    final saved = (await db.getAllConfigs()).single;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: TokenFormScreen(initialEntry: saved),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final issuer = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.controller?.text == account.issuer,
    );
    await tester.enterText(issuer, 'Unsaved');
    await tester.ensureVisible(find.text('Show saved account QR code'));
    await tester.tap(find.text('Show saved account QR code'));
    await tester.pumpAndSettle();
    expect(find.textContaining('account secret in plain text'), findsOneWidget);
    expect(find.byKey(const ValueKey('account_qr')), findsNothing);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('account_qr')), findsNothing);
    await tester.tap(find.text('Show saved account QR code'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('account_qr')), findsOneWidget);
    expect(
      tester.widget<AccountQr>(find.byType(AccountQr)).account.issuer,
      account.issuer,
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('account_qr')), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(milliseconds: 10));
  });
}
