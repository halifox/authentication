import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/storage/password_key.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('decrypts an independently generated AES-GCM and PBKDF2 vector', () async {
    const envelope =
        '{"version":1,"kdf":"pbkdf2-sha256","iterations":600000,"salt":"AAECAwQFBgcICQoLDA0ODw==","nonce":"AAECAwQFBgcICQoL","ciphertext":"vcm2D1YEETbRjqrPVGIZu1u0PAZXui2TVGI4MCpJwFIrJxpIw+GtvVs0ERBCmW4n"}';
    expect(
      await unwrapDeviceKey(envelope, 'independent-password'),
      Uint8List.fromList(List.generate(32, (index) => index)),
    );
  });
  test('device key envelope authenticates passwords and tampering', () async {
    final key = Uint8List.fromList(List.generate(32, (index) => index));
    final first = await wrapDeviceKey(key, 'old-password');
    final second = await wrapDeviceKey(key, 'old-password');
    expect(first, isNot(second));
    expect(await unwrapDeviceKey(first, 'old-password'), key);
    await expectLater(
      unwrapDeviceKey(first, 'wrong-password'),
      throwsFormatException,
    );
    final data = jsonDecode(first) as Map<String, dynamic>;
    final ciphertext = base64Decode(data['ciphertext'] as String);
    ciphertext[0] ^= 1;
    data['ciphertext'] = base64Encode(ciphertext);
    await expectLater(
      unwrapDeviceKey(jsonEncode(data), 'old-password'),
      throwsFormatException,
    );
    final changed = await wrapDeviceKey(
      await unwrapDeviceKey(first, 'old-password'),
      'new-password',
    );
    expect(await unwrapDeviceKey(changed, 'new-password'), key);
    await expectLater(
      unwrapDeviceKey(changed, 'old-password'),
      throwsFormatException,
    );
    data['iterations'] = 1;
    await expectLater(
      unwrapDeviceKey(jsonEncode(data), 'old-password'),
      throwsFormatException,
    );
  });
}
