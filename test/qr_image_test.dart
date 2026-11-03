import 'dart:typed_data';

import 'package:authentication/actions/qr_actions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as image;
import 'package:qr/qr.dart';

void main() {
  test('decodes transparent QR images and rejects oversized images', () {
    const value =
        'otpauth://totp/Example:user?secret=JBSWY3DPEHPK3PXP&issuer=Example';
    final qr = QrImage(QrCode(payload: QrPayload.fromString(value)));
    final bitmap = image.Image(
      width: (qr.moduleCount + 8) * 4,
      height: (qr.moduleCount + 8) * 4,
      numChannels: 4,
    );
    for (var y = 0; y < qr.moduleCount; y++) {
      for (var x = 0; x < qr.moduleCount; x++) {
        if (qr.isDark(y, x)) {
          image.fillRect(
            bitmap,
            x1: (x + 4) * 4,
            y1: (y + 4) * 4,
            x2: (x + 5) * 4 - 1,
            y2: (y + 5) * 4 - 1,
            color: image.ColorRgba8(0, 0, 0, 255),
          );
        }
      }
    }
    expect(decodeQrImage(Uint8List.fromList(image.encodePng(bitmap))), value);
    final oversized = image.Image(width: 4097, height: 1);
    expect(
      () => decodeQrImage(Uint8List.fromList(image.encodePng(oversized))),
      throwsFormatException,
    );
    expect(
      () => decodeQrImage(Uint8List(maxQrImageBytes + 1)),
      throwsFormatException,
    );
  });
}
