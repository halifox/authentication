import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/otp/account.dart';
import 'package:qr/qr.dart';

/// Encodes a self-contained, unencrypted, printable document. All accounts
/// must be representable as standard QR codes; nothing is silently omitted.
Uint8List encodeHtmlBackup(
  List<OtpAccount> accounts, {
  required String title,
  required String warning,
}) {
  if (accounts.isEmpty || accounts.length > 10000) {
    throw const FormatException('Invalid account list.');
  }
  final escape = const HtmlEscape();
  final output = StringBuffer('''<!doctype html>
<html><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>${escape.convert(title)}</title><style>
body { font-family: sans-serif; margin: 1.5rem; } article { display: inline-block; vertical-align: top; width: 18rem; max-width: 100%; margin: 1rem; break-inside: avoid; }
svg { display: block; width: 100%; max-width: 18rem; height: auto; } h2, p { overflow-wrap: anywhere; }
@media print { body { margin: 0; } article { page-break-inside: avoid; } }
</style></head><body><h1>${escape.convert(title)}</h1><p>${escape.convert(warning)}</p>
''');
  for (final account in accounts) {
    final uri = toStandardOtpQrUri(account);
    if (uri.length > 2048) {
      throw const FormatException('Account is too large.');
    }
    final image = QrImage(QrCode(payload: QrPayload.fromString(uri)));
    final size = image.moduleCount + 8;
    // The document uses an 18rem symbol; keep modules large enough on a
    // typical 96-dpi display instead of emitting an impractically dense code.
    if (size > 144) {
      throw const FormatException('QR code is too dense.');
    }
    output.write(
      '<article><h2>${escape.convert(account.issuer)}</h2>'
      '<p>${escape.convert(account.account)}</p>'
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $size $size" role="img" aria-label="${escape.convert(title)}" shape-rendering="crispEdges">'
      '<rect width="$size" height="$size" fill="white"/><path fill="black" d="',
    );
    for (var row = 0; row < image.moduleCount; row++) {
      for (var column = 0; column < image.moduleCount; column++) {
        if (image.isDark(row, column)) {
          output.write('M${column + 4} ${row + 4}h1v1h-1z');
        }
      }
    }
    output.write('"></path></svg></article>\n');
    if (output.length > maxBackupBytes) {
      throw const FormatException('File is too large.');
    }
  }
  output.write('</body></html>');
  final bytes = Uint8List.fromList(utf8.encode(output.toString()));
  if (bytes.length > maxBackupBytes) {
    throw const FormatException('File is too large.');
  }
  return bytes;
}
