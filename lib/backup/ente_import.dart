import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:pointycastle/export.dart' as pc;

/// Reads a version 1 password-protected URI-list export. Resource limits are
/// checked before key derivation so an untrusted file cannot request arbitrary work.
Future<Uint8List> decryptEnteBackup(Uint8List bytes, String password) async {
  if (bytes.isEmpty ||
      bytes.length > maxBackupBytes ||
      password.isEmpty ||
      password.length > 1024) {
    throw const FormatException('Invalid backup or password.');
  }
  try {
    final data = jsonDecode(utf8.decode(bytes));
    if (data is! Map<String, dynamic> ||
        data['version'] != 1 ||
        data['kdfParams'] is! Map<String, dynamic> ||
        data['encryptedData'] is! String ||
        data['encryptionNonce'] is! String) {
      throw const FormatException();
    }
    final params = data['kdfParams'] as Map<String, dynamic>;
    final memory = params['memLimit'];
    final iterations = params['opsLimit'];
    if (memory is! int ||
        memory < 8192 ||
        memory > 268435456 ||
        memory % 1024 != 0 ||
        iterations is! int ||
        iterations < 1 ||
        iterations > 16 ||
        params['salt'] is! String) {
      throw const FormatException();
    }
    final salt = base64Decode(params['salt'] as String);
    final header = base64Decode(data['encryptionNonce'] as String);
    final ciphertext = base64Decode(data['encryptedData'] as String);
    if (salt.length != 16 ||
        header.length != 24 ||
        ciphertext.length < 17 ||
        ciphertext.length > maxBackupBytes) {
      throw const FormatException();
    }
    return await compute(_decrypt, (
      password,
      salt,
      header,
      ciphertext,
      memory ~/ 1024,
      iterations,
    ));
  } catch (_) {
    throw const FormatException(
      'Incorrect password or damaged or unsupported backup.',
    );
  }
}

Uint8List _decrypt((String, Uint8List, Uint8List, Uint8List, int, int) input) {
  final (password, salt, header, ciphertext, memory, iterations) = input;
  final parameters = pc.Argon2Parameters(
    pc.Argon2Parameters.ARGON2_id,
    salt,
    desiredKeyLength: 32,
    iterations: iterations,
    memory: memory,
    lanes: 1,
    version: pc.Argon2Parameters.ARGON2_VERSION_13,
  );
  final key = (pc.Argon2BytesGenerator()..init(parameters)).process(
    Uint8List.fromList(utf8.encode(password)),
  );
  final keyData = SecretKeyData(key);
  final subkey = const DartHChacha20().deriveKeySync(
    secretKeyData: keyData,
    nonce: header.sublist(0, 16),
  );
  try {
    final nonce = Uint8List(12)
      ..[0] = 1
      ..setRange(4, 12, header.sublist(16));
    final cipher =
        const DartChacha20(macAlgorithm: MacAlgorithm.empty).newState()
          ..initializeSync(isEncrypting: true, secretKey: subkey, nonce: nonce);
    final stream = Uint8List.fromList(cipher.convertChunkSync(Uint8List(128)));
    final polyKey = SecretKeyData(stream.sublist(0, 32));
    try {
      final block = Uint8List.sublistView(stream, 64, 128);
      final tag = ciphertext[0] ^ block[0];
      block[0] = ciphertext[0];
      final length = ciphertext.length - 17;
      final macInput = BytesBuilder(copy: false)
        ..add(block)
        ..add(Uint8List.sublistView(ciphertext, 1, 1 + length))
        ..add(Uint8List(length & 15));
      final lengths = ByteData(16)..setUint32(8, 64 + length, Endian.little);
      macInput.add(lengths.buffer.asUint8List());
      final mac = const DartPoly1305().calculateMacSync(
        macInput.takeBytes(),
        secretKeyData: polyKey,
        nonce: const [],
      );
      if (mac != Mac(ciphertext.sublist(1 + length)) ||
          (tag != 0 && tag != 3)) {
        throw const FormatException();
      }
      return Uint8List.fromList(
        cipher.convertChunkSync(
          Uint8List.sublistView(ciphertext, 1, 1 + length),
        ),
      );
    } finally {
      polyKey.destroy();
      stream.fillRange(0, stream.length, 0);
    }
  } finally {
    subkey.destroy();
    keyData.destroy();
    key.fillRange(0, key.length, 0);
  }
}
