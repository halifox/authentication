import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';

/// Parsed KDBX header. This does not authenticate or decrypt the database.
class KdbxHeader {
  const KdbxHeader({
    required this.bytes,
    required this.fields,
    required this.kdf,
  });
  final Uint8List bytes;
  final Map<int, Uint8List> fields;
  final Map<String, Object> kdf;
}

/// Rejects malformed and computationally excessive KDBX 4 headers before KDF.
KdbxHeader readKdbxHeader(Uint8List input) {
  if (input.length < 12 || input.length > maxBackupBytes) {
    throw const FormatException('Invalid database size.');
  }
  final data = ByteData.sublistView(input);
  if (data.getUint32(0, Endian.little) != 0x9aa2d903 ||
      data.getUint32(4, Endian.little) != 0xb54bfb67 ||
      data.getUint16(10, Endian.little) != 4 ||
      data.getUint16(8, Endian.little) > 1) {
    throw const FormatException('Unsupported database format.');
  }
  var offset = 12;
  final fields = <int, Uint8List>{};
  while (true) {
    if (offset + 5 > input.length) {
      throw const FormatException('Truncated header.');
    }
    final id = input[offset];
    final length = data.getUint32(offset + 1, Endian.little);
    offset += 5;
    if (length > input.length - offset) {
      throw const FormatException('Truncated header.');
    }
    final value = Uint8List.sublistView(input, offset, offset + length);
    offset += length;
    if (id == 0) {
      if (length != 4 ||
          value[0] != 13 ||
          value[1] != 10 ||
          value[2] != 13 ||
          value[3] != 10 ||
          offset + 64 > input.length) {
        throw const FormatException('Invalid header terminator.');
      }
      break;
    }
    if (fields.containsKey(id)) {
      throw const FormatException('Repeated header field.');
    }
    if (!const [1, 2, 3, 4, 7, 11, 12].contains(id)) {
      throw const FormatException('Unsupported header field.');
    }
    fields[id] = value;
  }
  final encoded = fields[11];
  if (encoded == null) throw const FormatException('Missing KDF parameters.');
  final kdf = _readKdf(encoded);
  final uuid = kdf[r'$UUID'];
  final salt = kdf['S'];
  if (uuid is! Uint8List ||
      uuid.length != 16 ||
      salt is! Uint8List ||
      salt.length != 32) {
    throw const FormatException('Invalid KDF parameters.');
  }
  const aes = [
    0xc9,
    0xd9,
    0xf3,
    0x9a,
    0x62,
    0x8a,
    0x44,
    0x60,
    0xbf,
    0x74,
    0x0d,
    0x08,
    0xc1,
    0x8a,
    0x4f,
    0xea,
  ];
  const argonD = [
    0xef,
    0x63,
    0x6d,
    0xdf,
    0x8c,
    0x29,
    0x44,
    0x4b,
    0x91,
    0xf7,
    0xa9,
    0xa4,
    0x03,
    0xe3,
    0x0a,
    0x0c,
  ];
  const argonId = [
    0x9e,
    0x29,
    0x8b,
    0x19,
    0x56,
    0xdb,
    0x47,
    0x73,
    0xb2,
    0x3d,
    0xfc,
    0x3e,
    0xc6,
    0xf0,
    0xa1,
    0xe6,
  ];
  bool matches(List<int> expected) =>
      List.generate(16, (i) => uuid[i] == expected[i]).every((v) => v);
  if (matches(aes)) {
    if (kdf.keys.any((key) => !const [r'$UUID', 'S', 'R'].contains(key))) {
      throw const FormatException('Unsupported KDF parameters.');
    }
    final rounds = kdf['R'];
    if (rounds is! int || rounds < 1 || rounds > 10000000) {
      throw const FormatException('Unsupported KDF cost.');
    }
  } else if (matches(argonD) || matches(argonId)) {
    if (kdf.keys.any(
      (key) => !const [r'$UUID', 'S', 'M', 'I', 'P', 'V'].contains(key),
    )) {
      throw const FormatException('Unsupported KDF parameters.');
    }
    final memory = kdf['M'];
    final iterations = kdf['I'];
    final lanes = kdf['P'];
    final version = kdf['V'];
    if (memory is! int ||
        memory < 8192 ||
        memory > 268435456 ||
        memory % 1024 != 0 ||
        iterations is! int ||
        iterations < 1 ||
        iterations > 16 ||
        lanes is! int ||
        lanes < 1 ||
        lanes > 8 ||
        version != 0x13 ||
        kdf.containsKey('K') ||
        kdf.containsKey('A')) {
      throw const FormatException('Unsupported KDF parameters.');
    }
  } else {
    throw const FormatException('Unsupported KDF.');
  }
  return KdbxHeader(
    bytes: Uint8List.sublistView(input, 0, offset),
    fields: fields,
    kdf: kdf,
  );
}

Map<String, Object> _readKdf(Uint8List bytes) {
  if (bytes.length < 3 || bytes[0] != 0 || bytes[1] != 1) {
    throw const FormatException('Unsupported parameter dictionary.');
  }
  final data = ByteData.sublistView(bytes);
  var offset = 2;
  final values = <String, Object>{};
  while (true) {
    if (offset >= bytes.length) {
      throw const FormatException('Truncated parameter dictionary.');
    }
    final type = bytes[offset++];
    if (type == 0) {
      if (offset != bytes.length) {
        throw const FormatException('Invalid parameter dictionary.');
      }
      break;
    }
    if (values.length >= 32) {
      throw const FormatException('Too many KDF parameters.');
    }
    if (offset + 4 > bytes.length) {
      throw const FormatException('Truncated parameter.');
    }
    final keyLength = data.getUint32(offset, Endian.little);
    offset += 4;
    if (keyLength == 0 ||
        keyLength > 128 ||
        keyLength > bytes.length - offset) {
      throw const FormatException('Invalid parameter name.');
    }
    final key = utf8.decode(
      Uint8List.sublistView(bytes, offset, offset + keyLength),
    );
    offset += keyLength;
    if (offset + 4 > bytes.length) {
      throw const FormatException('Truncated parameter.');
    }
    final length = data.getUint32(offset, Endian.little);
    offset += 4;
    if (length > bytes.length - offset || values.containsKey(key)) {
      throw const FormatException('Invalid parameter.');
    }
    if (type == 0x42) {
      values[key] = Uint8List.sublistView(bytes, offset, offset + length);
    } else if (type == 4 && length == 4) {
      values[key] = data.getUint32(offset, Endian.little);
    } else if (type == 5 && length == 8) {
      final high = data.getUint32(offset + 4, Endian.little);
      if (high > 0x1fffff) throw const FormatException('Parameter too large.');
      values[key] = high * 4294967296 + data.getUint32(offset, Endian.little);
    } else {
      throw const FormatException('Unsupported parameter.');
    }
    offset += length;
  }
  return values;
}
