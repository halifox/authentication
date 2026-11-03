import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/category.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

import 'backup_key.dart' if (dart.library.js_interop) 'backup_key_web.dart';

enum LegacyBackupFormat { plain, encrypted, encryptedOld }

typedef LegacyImport = ({
  List<OtpAccount> accounts,
  List<AccountCategory> categories,
  Map<(String, String), List<String>> memberships,
});

Future<Uint8List> decryptLegacyBackup(
  Uint8List bytes,
  LegacyBackupFormat format, {
  String? password,
}) async {
  if (bytes.isEmpty || bytes.length > maxBackupBytes) {
    throw const FormatException('Invalid backup size.');
  }
  Uint8List plaintext = bytes;
  if (format != LegacyBackupFormat.plain) {
    if (password == null || password.isEmpty) {
      throw const FormatException('Password required.');
    }
    try {
      late Uint8List key;
      late Uint8List encrypted;
      if (format == LegacyBackupFormat.encrypted) {
        if (bytes.length < 44) throw const FormatException();
        final iterations = ByteData.sublistView(bytes, 0, 4).getUint32(0);
        if (iterations == 0 || iterations > 1000000) {
          throw const FormatException();
        }
        key = await deriveBackupKey(
          password,
          bytes.sublist(4, 16),
          iterations,
          sha1: true,
        );
        encrypted = bytes.sublist(16);
      } else {
        if (bytes.length < 28) throw const FormatException();
        key = Uint8List.fromList(sha256.convert(utf8.encode(password)).bytes);
        encrypted = bytes;
      }
      final cipher = enc.Encrypter(
        enc.AES(enc.Key(key), mode: enc.AESMode.gcm),
      );
      plaintext = Uint8List.fromList(
        cipher.decryptBytes(
          enc.Encrypted(encrypted.sublist(12)),
          iv: enc.IV(encrypted.sublist(0, 12)),
        ),
      );
    } catch (_) {
      throw const FormatException('Incorrect password or damaged backup.');
    }
  }
  return plaintext;
}

LegacyImport parseLegacyBackup(Uint8List plaintext) {
  if (plaintext.isEmpty || plaintext.length > maxBackupBytes) {
    throw const FormatException('Invalid backup size.');
  }
  try {
    final data = jsonDecode(utf8.decode(plaintext));
    if (data is! List || data.isEmpty || data.length > 10000) {
      throw const FormatException();
    }
    final accounts = <OtpAccount>[];
    final categoryNames = <String>{};
    final memberships = <(String, String), List<String>>{};
    final keys = <(String, String)>{};
    for (final item in data) {
      if (item is! Map<String, dynamic>) throw const FormatException();
      final type = (item['type'] ?? 'TOTP');
      final algorithm = (item['algorithm'] ?? 'SHA1');
      final issuer = item['issuer'];
      final label = item['label'];
      final secret = item['secret'];
      if (type is! String ||
          algorithm is! String ||
          issuer is! String ||
          label is! String ||
          secret is! String) {
        throw const FormatException();
      }
      final normalizedType = type.toLowerCase();
      if (!const ['totp', 'hotp', 'steam'].contains(normalizedType)) {
        throw const FormatException();
      }
      if (normalizedType == 'steam' && algorithm.toLowerCase() != 'sha1') {
        throw const FormatException();
      }
      final digits = item['digits'] ?? (normalizedType == 'steam' ? 5 : 6);
      final period = item['period'] ?? 30;
      final counter = item['counter'] ?? (normalizedType == 'hotp' ? null : 0);
      if (digits is! int || period is! int || counter is! int) {
        throw const FormatException();
      }
      final account = OtpAccount(
        type: normalizedType,
        issuer: issuer,
        account: label,
        secret: secret.trim().toUpperCase(),
        algorithm: algorithm.toLowerCase(),
        digits: digits,
        period: period,
        counter: counter,
      );
      account.validate();
      if (!keys.add((account.issuer, account.account))) {
        throw const FormatException();
      }
      final tags = item['tags'] ?? const [];
      if (tags is! List || tags.any((tag) => tag is! String)) {
        throw const FormatException();
      }
      final names = <String>{};
      for (final tag in tags.cast<String>()) {
        if (validateCategoryName(tag) != tag) throw const FormatException();
        names.add(tag);
        categoryNames.add(tag);
      }
      memberships[(account.issuer, account.account)] = names.toList();
      accounts.add(account);
    }
    final categories = [
      for (final name in categoryNames) AccountCategory(name: name),
    ];
    validateCategories(categories);
    return (
      accounts: accounts,
      categories: categories,
      memberships: memberships,
    );
  } catch (_) {
    throw const FormatException('Invalid or unsupported backup contents.');
  }
}
