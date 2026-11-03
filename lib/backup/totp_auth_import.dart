import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/legacy_import.dart';
import 'package:authentication/otp/account.dart';
import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

LegacyImport parseTotpAuthBackup(Uint8List bytes, String password) {
  if (bytes.isEmpty ||
      bytes.length > maxBackupBytes ||
      password.isEmpty ||
      password.length > 1024) {
    throw const FormatException('Invalid backup or password.');
  }
  try {
    final ciphertext = base64Decode(utf8.decode(bytes).trim());
    if (ciphertext.isEmpty || ciphertext.length % 16 != 0) {
      throw const FormatException();
    }
    final key = sha256.convert(utf8.encode(password)).bytes;
    final cipher = enc.Encrypter(
      enc.AES(enc.Key(Uint8List.fromList(key)), mode: enc.AESMode.cbc),
    );
    final plaintext = cipher.decryptBytes(
      enc.Encrypted(ciphertext),
      iv: enc.IV(Uint8List(16)),
    );
    final wrapper = jsonDecode(utf8.decode(plaintext));
    if (wrapper is! Map<String, dynamic> ||
        wrapper.length != 1 ||
        wrapper.values.single is! String) {
      throw const FormatException();
    }
    final entries = jsonDecode(wrapper.keys.single);
    if (entries is! List || entries.isEmpty || entries.length > 10000) {
      throw const FormatException();
    }
    final accounts = <OtpAccount>[];
    final keys = <(String, String)>{};
    final memberships = <(String, String), List<String>>{};
    for (final entry in entries) {
      if (entry is! Map<String, dynamic> ||
          entry['issuer'] is! String ||
          entry['name'] is! String ||
          entry['key'] is! String ||
          entry['digits'] is! String ||
          entry['period'] is! String ||
          entry['base'] != 16) {
        throw const FormatException();
      }
      final issuer = entry['issuer'] as String;
      final name = entry['name'] as String;
      final actualIssuer = issuer == 'Unknown' || issuer.trim().isEmpty
          ? name
          : issuer;
      final actualName = name.trim().isEmpty ? actualIssuer : name;
      final hex = entry['key'] as String;
      if (hex.isEmpty ||
          hex.length.isOdd ||
          !RegExp(r'^[0-9a-fA-F]+$').hasMatch(hex)) {
        throw const FormatException();
      }
      final secret = base32.encode(
        Uint8List.fromList([
          for (var i = 0; i < hex.length; i += 2)
            int.parse(hex.substring(i, i + 2), radix: 16),
        ]),
      );
      final digitsText = entry['digits'] as String;
      final periodText = entry['period'] as String;
      final digits = digitsText.isEmpty ? 6 : int.parse(digitsText);
      final period = periodText.isEmpty ? 30 : int.parse(periodText);
      final account = OtpAccount(
        type: 'totp',
        issuer: actualIssuer,
        account: actualName,
        secret: secret,
        digits: digits,
        period: period,
      );
      account.validate();
      final key = (account.issuer, account.account);
      if (!keys.add(key)) throw const FormatException();
      accounts.add(account);
      memberships[key] = [];
    }
    return (accounts: accounts, categories: [], memberships: memberships);
  } catch (_) {
    throw const FormatException(
      'Incorrect password or invalid or unsupported backup.',
    );
  }
}
