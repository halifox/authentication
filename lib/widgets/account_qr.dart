import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/account.dart';
import 'package:flutter/material.dart';
import 'package:qr/qr.dart';

/// The symbol contains an unencrypted account secret; callers must warn first.
class AccountQr extends StatelessWidget {
  const AccountQr({required this.account, super.key});

  final OtpAccount account;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    try {
      account.validate();
      if (account.type.toLowerCase() != 'totp' &&
          account.type.toLowerCase() != 'hotp') {
        return Text(l10n.qrUnsupportedAccount);
      }
      final uri = toStandardOtpQrUri(account);
      if (uri.length > 2048) return Text(l10n.qrTooLarge);
      final image = QrImage(QrCode(payload: QrPayload.fromString(uri)));
      return LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth.clamp(0.0, 320.0);
          if (size / (image.moduleCount + 8) < 2) {
            return Text(l10n.qrTooLarge);
          }
          return Center(
            child: RepaintBoundary(
              key: const ValueKey('account_qr'),
              child: Semantics(
                label: l10n.qrSecretSemantics,
                child: CustomPaint(
                  size: Size.square(size),
                  painter: _QrPainter(image),
                ),
              ),
            ),
          );
        },
      );
    } on FormatException {
      return Text(l10n.qrUnsupportedParameters);
    } catch (_) {
      return Text(l10n.qrTooLarge);
    }
  }
}

class _QrPainter extends CustomPainter {
  const _QrPainter(this.image);
  final QrImage image;

  @override
  void paint(Canvas canvas, Size size) {
    final total = image.moduleCount + 8;
    final module = (size.shortestSide / total).floorToDouble();
    final left = ((size.width - total * module) / 2).floorToDouble();
    final top = ((size.height - total * module) / 2).floorToDouble();
    canvas.drawRect(Offset.zero & size, Paint()..color = Colors.white);
    final black = Paint()
      ..color = Colors.black
      ..isAntiAlias = false;
    for (var row = 0; row < image.moduleCount; row++) {
      for (var column = 0; column < image.moduleCount; column++) {
        if (image.isDark(row, column)) {
          canvas.drawRect(
            Rect.fromLTWH(
              left + (column + 4) * module,
              top + (row + 4) * module,
              module,
              module,
            ),
            black,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) => oldDelegate.image != image;
}
