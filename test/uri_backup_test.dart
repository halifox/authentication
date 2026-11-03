import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:authentication/backup/uri_backup_import.dart';
import 'package:authentication/otp/otp.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'independent plain and encrypted exports decrypt and validate',
    () async {
      final plain = await File('test/fixtures/uri_backup/plain.json')
          .readAsBytes();
      final encrypted = await File('test/fixtures/uri_backup/encrypted.json')
          .readAsBytes();
      expect(isUriBackupEncrypted(plain), false);
      expect(isUriBackupEncrypted(encrypted), true);
      final doc = parseUriBackup(plain);
      expect(doc.accounts.length, 3);
      final decrypted = await decryptUriBackup(encrypted, password: 'test');
      final json = jsonDecode(utf8.decode(decrypted)) as Map<String, dynamic>;
      expect(json['version'], 1);
      expect((json['entries'] as List).isNotEmpty, true);
      final encryptedDoc = parseUriBackup(decrypted);
      expect(encryptedDoc.accounts.isNotEmpty, true);
      await expectLater(
        decryptUriBackup(encrypted, password: 'wrong'),
        throwsFormatException,
      );
      final envelope =
          jsonDecode(utf8.decode(encrypted)) as Map<String, dynamic>;
      final ciphertext = base64Decode(envelope['content'] as String);
      ciphertext[ciphertext.length - 1] ^= 1;
      envelope['content'] = base64Encode(ciphertext);
      await expectLater(
        decryptUriBackup(
          Uint8List.fromList(utf8.encode(jsonEncode(envelope))),
          password: 'test',
        ),
        throwsFormatException,
      );
    },
  );
  test(
    'Steam conversion matches a source test vector and rejects duplicates',
    () {
      final data = {
        'version': 1,
        'entries': [
          {
            'id': '1',
            'content': {
              'entry_type': 'Steam',
              'uri': 'steam://STEAMKEY',
              'name': null,
            },
          },
        ],
      };
      Uint8List bytes(Object value) =>
          Uint8List.fromList(utf8.encode(jsonEncode(value)));
      final account = parseUriBackup(bytes(data)).accounts.single;
      expect(account.account, 'Steam');
      expect(
        OTP.generateSteamCode(
          secret: account.secret,
          unixMilliseconds: 1742298317000,
        ),
        'VKFDN',
      );
      final entry = (data['entries'] as List).first;
      expect(
        () => parseUriBackup(
          bytes({
            ...data,
            'entries': [entry, entry],
          }),
        ),
        throwsFormatException,
      );
      final invalid = {
        'version': 1,
        'entries': [
          {
            'id': '2',
            'content': {
              'entry_type': 'Totp',
              'uri': 'otpauth://totp/Example:user?secret=A&issuer=Example',
              'name': 'user',
            },
          },
        ],
      };
      expect(() => parseUriBackup(bytes(invalid)), throwsFormatException);
    },
  );
}
