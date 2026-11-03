import 'dart:io';
import 'dart:typed_data';

import 'package:authentication/backup/totp_auth_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decrypts independent sample and rejects incorrect or damaged data', () {
    final bytes = File('test/fixtures/totp_auth/encrypted.bin')
        .readAsBytesSync();
    final result = parseTotpAuthBackup(bytes, 'Testtest1');
    expect(result.accounts.length, 2);
    expect(result.accounts.every((a) => a.type == 'totp'), isTrue);
    expect(() => parseTotpAuthBackup(bytes, 'wrong'), throwsFormatException);
    expect(
      () => parseTotpAuthBackup(
        Uint8List.fromList(bytes.sublist(0, 15)),
        'Testtest1',
      ),
      throwsFormatException,
    );
  });
}
