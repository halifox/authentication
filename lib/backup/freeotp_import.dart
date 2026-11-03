import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/legacy_import.dart';
import 'package:authentication/otp/account.dart';
import 'package:base32/base32.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart' show compute;
import 'package:pointycastle/export.dart' as pc;

const _header = <int>[
  0xac,
  0xed,
  0x00,
  0x05,
  0x73,
  0x72,
  0x00,
  0x11,
  0x6a,
  0x61,
  0x76,
  0x61,
  0x2e,
  0x75,
  0x74,
  0x69,
  0x6c,
  0x2e,
  0x48,
  0x61,
  0x73,
  0x68,
  0x4d,
  0x61,
  0x70,
  0x05,
  0x07,
  0xda,
  0xc1,
  0xc3,
  0x16,
  0x60,
  0xd1,
  0x03,
  0x00,
  0x02,
  0x46,
  0x00,
  0x0a,
  0x6c,
  0x6f,
  0x61,
  0x64,
  0x46,
  0x61,
  0x63,
  0x74,
  0x6f,
  0x72,
  0x49,
  0x00,
  0x09,
  0x74,
  0x68,
  0x72,
  0x65,
  0x73,
  0x68,
  0x6f,
  0x6c,
  0x64,
  0x78,
  0x70,
];

String _modifiedUtf8(Uint8List input) {
  final units = <int>[];
  for (var i = 0; i < input.length;) {
    final a = input[i++];
    if (a >= 1 && a <= 0x7f) {
      units.add(a);
    } else if (a >= 0xc0 && a <= 0xdf && i < input.length) {
      final b = input[i++];
      if ((b & 0xc0) != 0x80) throw const FormatException();
      final value = ((a & 31) << 6) | (b & 63);
      if (value < 0x80 && value != 0) throw const FormatException();
      units.add(value);
    } else if (a >= 0xe0 && a <= 0xef && i + 1 < input.length) {
      final b = input[i++], c = input[i++];
      if ((b & 0xc0) != 0x80 || (c & 0xc0) != 0x80) {
        throw const FormatException();
      }
      final value = ((a & 15) << 12) | ((b & 63) << 6) | (c & 63);
      if (value < 0x800) throw const FormatException();
      units.add(value);
    } else {
      throw const FormatException();
    }
  }
  for (var i = 0; i < units.length; i++) {
    if (units[i] >= 0xd800 && units[i] <= 0xdbff) {
      if (++i >= units.length || units[i] < 0xdc00 || units[i] > 0xdfff) {
        throw const FormatException();
      }
    } else if (units[i] >= 0xdc00 && units[i] <= 0xdfff) {
      throw const FormatException();
    }
  }
  return String.fromCharCodes(units);
}

Map<String, String> _readMap(Uint8List bytes) {
  if (bytes.length < _header.length + 19 ||
      !_header.asMap().entries.every((e) => bytes[e.key] == e.value)) {
    throw const FormatException();
  }
  var offset = _header.length + 8; // serialized load factor and threshold
  if (bytes[offset++] != 0x77 || bytes[offset++] != 8) {
    throw const FormatException();
  }
  final block = ByteData.sublistView(bytes, offset, offset + 8);
  final count = block.getUint32(4);
  offset += 8;
  if (count < 1 || count > 20001) throw const FormatException();
  String readString() {
    if (offset + 3 > bytes.length || bytes[offset++] != 0x74) {
      throw const FormatException();
    }
    final length = (bytes[offset++] << 8) | bytes[offset++];
    if (offset + length > bytes.length) throw const FormatException();
    final result = _modifiedUtf8(bytes.sublist(offset, offset + length));
    offset += length;
    return result;
  }

  final values = <String, String>{};
  for (var i = 0; i < count; i++) {
    final key = readString();
    final value = readString();
    if (values.containsKey(key)) throw const FormatException();
    values[key] = value;
  }
  if (offset != bytes.length - 1 || bytes[offset] != 0x78) {
    throw const FormatException();
  }
  return values;
}

Uint8List _signedBytes(Object? value) {
  if (value is! List || value.any((v) => v is! int || v < -128 || v > 127)) {
    throw const FormatException();
  }
  return Uint8List.fromList(value.cast<int>().map((v) => v & 255).toList());
}

Uint8List _decryptKey(Object? value, Uint8List key) {
  if (value is! Map<String, dynamic> ||
      value['mCipher'] != 'AES/GCM/NoPadding' ||
      value['mToken'] is! String) {
    throw const FormatException();
  }
  final params = _signedBytes(value['mParameters']);
  final ciphertext = _signedBytes(value['mCipherText']);
  if (params.length != 19 ||
      params[0] != 0x30 ||
      params[1] != 0x11 ||
      params[2] != 4 ||
      params[3] != 12 ||
      params[16] != 2 ||
      params[17] != 1 ||
      params[18] != 16 ||
      ciphertext.length < 16) {
    throw const FormatException();
  }
  final cipher = enc.Encrypter(enc.AES(enc.Key(key), mode: enc.AESMode.gcm));
  return Uint8List.fromList(
    cipher.decryptBytes(
      enc.Encrypted(ciphertext),
      iv: enc.IV(params.sublist(4, 16)),
      associatedData: Uint8List.fromList(
        utf8.encode(value['mToken'] as String),
      ),
    ),
  );
}

LegacyImport _parseFreeOtp((Uint8List, String) args) {
  final bytes = args.$1;
  final password = args.$2;
  if (bytes.isEmpty ||
      bytes.length > maxBackupBytes ||
      password.isEmpty ||
      password.length > 1024) {
    throw const FormatException('Invalid backup or password.');
  }
  try {
    final values = _readMap(bytes);
    final master = jsonDecode(values['masterKey']!);
    if (master is! Map<String, dynamic> || master['mIterations'] is! int) {
      throw const FormatException();
    }
    final iterations = master['mIterations'] as int;
    final salt = _signedBytes(master['mSalt']);
    if (iterations < 1 ||
        iterations > 1000000 ||
        salt.length < 16 ||
        salt.length > 64) {
      throw const FormatException();
    }
    final digest = switch (master['mAlgorithm']) {
      'PBKDF2withHmacSHA1' => pc.SHA1Digest(),
      'PBKDF2withHmacSHA512' => pc.SHA512Digest(),
      _ => throw const FormatException(),
    };
    final hmacBlockSize = master['mAlgorithm'] == 'PBKDF2withHmacSHA512'
        ? 128
        : 64;
    final derivator = pc.PBKDF2KeyDerivator(pc.HMac(digest, hmacBlockSize))
      ..init(pc.Pbkdf2Parameters(salt, iterations, 32));
    final key = derivator.process(Uint8List.fromList(utf8.encode(password)));
    final masterKey = _decryptKey(master['mEncryptedKey'], key);
    if (masterKey.length != 32) throw const FormatException();
    final tokens = values.keys.where((key) => key.endsWith('-token')).toList();
    if (tokens.isEmpty ||
        tokens.length > 10000 ||
        values.length != tokens.length * 2 + 1) {
      throw const FormatException();
    }
    final accounts = <OtpAccount>[];
    final keys = <(String, String)>{};
    final memberships = <(String, String), List<String>>{};
    for (final tokenKey in tokens) {
      final token = jsonDecode(values[tokenKey]!);
      final associated = values[tokenKey.substring(0, tokenKey.length - 6)];
      if (token is! Map<String, dynamic> ||
          associated == null ||
          token['label'] is! String ||
          (token['issuerExt'] != null && token['issuerExt'] is! String)) {
        throw const FormatException();
      }
      final keyWrapper = jsonDecode(associated);
      if (keyWrapper is! Map<String, dynamic> || keyWrapper['key'] is! String) {
        throw const FormatException();
      }
      final secret = _decryptKey(
        jsonDecode(keyWrapper['key'] as String),
        masterKey,
      );
      if (secret.isEmpty) throw const FormatException();
      final type = switch (token['type']) {
        'TOTP' => 'totp',
        'HOTP' => 'hotp',
        _ => throw const FormatException(),
      };
      final algorithm = switch (token['algo']) {
        null || 'SHA1' => 'sha1',
        'SHA256' => 'sha256',
        'SHA512' => 'sha512',
        _ => throw const FormatException(),
      };
      final label = token['label'] as String;
      final issuer = token['issuerExt'] as String?;
      final digits = token['digits'] ?? 6,
          period = token['period'] ?? 30,
          counter = token['counter'] ?? 0;
      if (digits is! int || period is! int || counter is! int) {
        throw const FormatException();
      }
      final account = OtpAccount(
        type: type,
        issuer: issuer == null || issuer.trim().isEmpty ? label : issuer,
        account: label,
        secret: base32.encode(secret),
        algorithm: algorithm,
        digits: digits,
        period: period,
        counter: counter,
      );
      account.validate();
      final accountKey = (account.issuer, account.account);
      if (!keys.add(accountKey)) throw const FormatException();
      accounts.add(account);
      memberships[accountKey] = [];
    }
    return (accounts: accounts, categories: [], memberships: memberships);
  } catch (_) {
    throw const FormatException(
      'Incorrect password or invalid or unsupported backup.',
    );
  }
}

Future<LegacyImport> parseFreeOtpBackup(Uint8List bytes, String password) =>
    compute(_parseFreeOtp, (bytes, password));
