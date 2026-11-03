import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/kdbx_header.dart';
import 'package:crypto/crypto.dart' as hash;
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart' show compute;
import 'package:pointycastle/export.dart' as pc;

Future<Uint8List> decryptKdbx(Uint8List bytes, String password) async {
  if (password.isEmpty || password.length > 1024) {
    throw const FormatException('Invalid password.');
  }
  try {
    return await compute(_decrypt, (bytes, password));
  } catch (_) {
    throw const FormatException(
      'Invalid password or unsupported or damaged database.',
    );
  }
}

Uint8List _digest(hash.Hash algorithm, List<int> bytes) =>
    Uint8List.fromList(algorithm.convert(bytes).bytes);
Uint8List _hmac(List<int> key, List<int> data) =>
    Uint8List.fromList(hash.Hmac(hash.sha256, key).convert(data).bytes);
Uint8List _join(List<List<int>> parts) =>
    Uint8List.fromList(parts.expand((part) => part).toList());
bool _equal(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  var diff = 0;
  for (var i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}

Uint8List _blockId(int value) {
  final b = ByteData(8)..setUint32(0, value, Endian.little);
  return b.buffer.asUint8List();
}

Uint8List _decrypt((Uint8List, String) input) {
  final (bytes, password) = input;
  final header = readKdbxHeader(bytes);
  final kdf = header.kdf;
  final salt = kdf['S'] as Uint8List;
  final composite = _digest(
    hash.sha256,
    _digest(hash.sha256, utf8.encode(password)),
  );
  Uint8List transformed;
  if (kdf.containsKey('R')) {
    final cipher = pc.AESEngine()..init(true, pc.KeyParameter(salt));
    transformed = Uint8List.fromList(composite);
    final result = Uint8List(32);
    for (var i = 0; i < (kdf['R'] as int); i++) {
      cipher.processBlock(transformed, 0, result, 0);
      cipher.processBlock(transformed, 16, result, 16);
      transformed.setAll(0, result);
    }
    transformed = _digest(hash.sha256, transformed);
  } else {
    final uuid = kdf[r'$UUID'] as Uint8List;
    final params = pc.Argon2Parameters(
      uuid[0] == 0xef
          ? pc.Argon2Parameters.ARGON2_d
          : pc.Argon2Parameters.ARGON2_id,
      salt,
      desiredKeyLength: 32,
      iterations: kdf['I'] as int,
      memory: (kdf['M'] as int) ~/ 1024,
      lanes: kdf['P'] as int,
      version: pc.Argon2Parameters.ARGON2_VERSION_13,
    );
    transformed = (pc.Argon2BytesGenerator()..init(params)).process(composite);
  }
  final seed = header.fields[4];
  final iv = header.fields[7];
  final cipherId = header.fields[2];
  final compression = header.fields[3];
  const aesId = [
    0x31,
    0xc1,
    0xf2,
    0xe6,
    0xbf,
    0x71,
    0x43,
    0x50,
    0xbe,
    0x58,
    0x05,
    0x21,
    0x6a,
    0xfc,
    0x5a,
    0xff,
  ];
  if (seed?.length != 32 ||
      iv?.length != 16 ||
      cipherId == null ||
      !_equal(cipherId, aesId) ||
      compression?.length != 4) {
    throw const FormatException();
  }
  final mode = ByteData.sublistView(compression!).getUint32(0, Endian.little);
  if (mode > 1) throw const FormatException();
  final offset = header.bytes.length;
  if (!_equal(
    _digest(hash.sha256, header.bytes),
    bytes.sublist(offset, offset + 32),
  )) {
    throw const FormatException();
  }
  final base = _digest(
    hash.sha512,
    _join([
      seed!,
      transformed,
      [1],
    ]),
  );
  final headerKey = _digest(
    hash.sha512,
    _join([Uint8List.fromList(List.filled(8, 255)), base]),
  );
  if (!_equal(
    _hmac(headerKey, header.bytes),
    bytes.sublist(offset + 32, offset + 64),
  )) {
    throw const FormatException();
  }
  final reader = ByteData.sublistView(bytes);
  var position = offset + 64;
  var index = 0;
  final encrypted = BytesBuilder(copy: false);
  var ended = false;
  while (position < bytes.length) {
    if (position + 36 > bytes.length) throw const FormatException();
    final tag = Uint8List.sublistView(bytes, position, position + 32);
    final size = reader.getUint32(position + 32, Endian.little);
    final sizeBytes = Uint8List.sublistView(
      bytes,
      position + 32,
      position + 36,
    );
    position += 36;
    if (size > bytes.length - position ||
        encrypted.length + size > maxBackupBytes) {
      throw const FormatException();
    }
    final block = Uint8List.sublistView(bytes, position, position + size);
    final id = _blockId(index++);
    final blockKey = _digest(hash.sha512, _join([id, base]));
    if (!_equal(tag, _hmac(blockKey, _join([id, sizeBytes, block])))) {
      throw const FormatException();
    }
    position += size;
    if (size == 0) {
      ended = true;
      break;
    }
    encrypted.add(block);
  }
  if (!ended || position != bytes.length) throw const FormatException();
  final master = _digest(hash.sha256, _join([seed, transformed]));
  final plain = enc.Encrypter(enc.AES(enc.Key(master), mode: enc.AESMode.cbc))
      .decryptBytes(enc.Encrypted(encrypted.takeBytes()), iv: enc.IV(iv!));
  final result = mode == 1
      ? const GZipDecoder().decodeBytes(
          plain,
          verify: true,
          maxOutputSize: maxBackupBytes,
          throwOnError: true,
        )
      : Uint8List.fromList(plain);
  if (result.length > maxBackupBytes) throw const FormatException();
  return Uint8List.fromList(result);
}
