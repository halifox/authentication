import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/backup_key.dart'
    if (dart.library.js_interop) 'package:authentication/backup/backup_key_web.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const entries = [
    {
      'uri': 'otpauth://totp/Test:user?secret=JBSWY3DPEHPK3PXP&issuer=Test',
      'icon': 'assets/icons/passkey.svg',
      'sortOrder': 0,
      'createdAt': 1,
    },
  ];
  test('PBKDF2 matches the native and web interoperability vector', () async {
    final key = await deriveBackupKey(
      'password',
      Uint8List.fromList(utf8.encode('1234567890123456')),
      600000,
    );
    expect(
      key.map((b) => b.toRadixString(16).padLeft(2, '0')).join(),
      '5ca816c929558b6e71b6c1e5d51343e2a005c298c107a6d5c9cb003bfb3c1e2b',
    );
  });
  test('unencrypted file round trips', () async {
    final bytes = await Backup.encode(entries, null);
    expect(Backup.isEncrypted(bytes), false);
    expect(await Backup.decode(bytes, null), entries);
  });
  test(
    'password protected file round trips and rejects wrong password or damage',
    () async {
      final bytes = await Backup.encode(entries, 'long passphrase');
      expect(utf8.decode(bytes), isNot(contains('JBSWY3DPEHPK3PXP')));
      expect(Backup.isEncrypted(bytes), true);
      expect(await Backup.decode(bytes, 'long passphrase'), entries);
      await expectLater(Backup.decode(bytes, 'wrong'), throwsFormatException);
      final json = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final ciphertext = json['ciphertext'] as String;
      json['ciphertext'] =
          '${ciphertext[0] == 'A' ? 'B' : 'A'}${ciphertext.substring(1)}';
      await expectLater(
        Backup.decode(
          Uint8List.fromList(utf8.encode(jsonEncode(json))),
          'long passphrase',
        ),
        throwsFormatException,
      );
    },
  );
  test('rejects unsupported and oversized files', () async {
    expect(
      () => Backup.isEncrypted(Uint8List.fromList(utf8.encode('{}'))),
      throwsFormatException,
    );
    expect(
      () => Backup.isEncrypted(Uint8List(maxBackupBytes + 1)),
      throwsFormatException,
    );
  });
}
