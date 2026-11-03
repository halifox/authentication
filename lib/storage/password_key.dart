import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as crypt;

import 'key_derivation.dart'
    if (dart.library.js_interop) 'key_derivation_web.dart';

const _iterations = 600000;

/// Wraps an existing device key. The ciphertext must replace the prior key
/// only after it has been independently verified and durably persisted.
Future<String> wrapDeviceKey(Uint8List deviceKey, String password) async {
  if (deviceKey.length != 32 || password.isEmpty || password.length > 1024) {
    throw const FormatException('Invalid key or password.');
  }
  final salt = crypt.Key.fromSecureRandom(16).bytes;
  final nonce = crypt.IV.fromSecureRandom(12);
  final key = await derivePbkdf2Key(password, salt, _iterations);
  try {
    final cipher = crypt.Encrypter(
      crypt.AES(crypt.Key(key), mode: crypt.AESMode.gcm),
    );
    final encrypted = cipher.encryptBytes(deviceKey, iv: nonce);
    return jsonEncode({
      'version': 1,
      'kdf': 'pbkdf2-sha256',
      'iterations': _iterations,
      'salt': base64Encode(salt),
      'nonce': nonce.base64,
      'ciphertext': encrypted.base64,
    });
  } finally {
    key.fillRange(0, key.length, 0);
  }
}

/// Rejects malformed, modified, or incorrectly authenticated envelopes.
Future<Uint8List> unwrapDeviceKey(String envelope, String password) async {
  if (envelope.length > 1024 || password.isEmpty || password.length > 1024) {
    throw const FormatException('Invalid password or key envelope.');
  }
  Uint8List? derived;
  try {
    final data = jsonDecode(envelope);
    if (data is! Map<String, dynamic> ||
        data.length != 6 ||
        data['version'] != 1 ||
        data['kdf'] != 'pbkdf2-sha256' ||
        data['iterations'] != _iterations ||
        data['salt'] is! String ||
        data['nonce'] is! String ||
        data['ciphertext'] is! String) {
      throw const FormatException();
    }
    final salt = base64Decode(data['salt'] as String);
    final nonce = base64Decode(data['nonce'] as String);
    final ciphertext = base64Decode(data['ciphertext'] as String);
    if (salt.length != 16 || nonce.length != 12 || ciphertext.length != 48) {
      throw const FormatException();
    }
    final key = await derivePbkdf2Key(password, salt, _iterations);
    derived = key;
    final cipher = crypt.Encrypter(
      crypt.AES(crypt.Key(key), mode: crypt.AESMode.gcm),
    );
    final result = Uint8List.fromList(
      cipher.decryptBytes(crypt.Encrypted(ciphertext), iv: crypt.IV(nonce)),
    );
    if (result.length != 32) throw const FormatException();
    return result;
  } catch (_) {
    throw const FormatException('Invalid password or key envelope.');
  } finally {
    derived?.fillRange(0, derived.length, 0);
  }
}
