import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/ente_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'decrypts independent authenticated export and rejects wrong password',
    () async {
      final bytes = File('test/fixtures/ente/encrypted.txt').readAsBytesSync();
      final plain = await decryptEnteBackup(bytes, 'password');
      final accounts = decodeUriList(plain, detectSteam: true);
      expect(accounts.length, 3);
      expect(
        accounts.map((account) => account.type),
        containsAll(['hotp', 'totp', 'steam']),
      );
      await expectLater(
        decryptEnteBackup(bytes, 'wrong'),
        throwsFormatException,
      );
      final data = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final ciphertext = base64Decode(data['encryptedData'] as String);
      ciphertext[10] ^= 1;
      data['encryptedData'] = base64Encode(ciphertext);
      await expectLater(
        decryptEnteBackup(
          Uint8List.fromList(utf8.encode(jsonEncode(data))),
          'password',
        ),
        throwsFormatException,
      );
      (data['kdfParams'] as Map<String, dynamic>)['memLimit'] = 1073741824;
      await expectLater(
        decryptEnteBackup(
          Uint8List.fromList(utf8.encode(jsonEncode(data))),
          'password',
        ),
        throwsFormatException,
      );
    },
  );
  test('imports independent plaintext export', () {
    final bytes = File('test/fixtures/ente/plain.txt').readAsBytesSync();
    final accounts = decodeUriList(bytes);
    expect(accounts.length, 7);
    expect(accounts.where((account) => account.type == 'hotp').length, 1);
    expect(accounts.any((account) => account.period == 60), isTrue);
  });
}
