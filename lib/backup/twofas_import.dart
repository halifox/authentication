import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/legacy_import.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/category.dart';
import 'package:base32/base32.dart';
import 'package:encrypt/encrypt.dart' as enc;

import 'backup_key.dart' if (dart.library.js_interop) 'backup_key_web.dart';

Map<String, dynamic> _readTwoFas(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > maxBackupBytes) {
    throw const FormatException('Invalid backup size.');
  }
  try {
    final data = jsonDecode(utf8.decode(bytes));
    if (data is! Map<String, dynamic> ||
        data['schemaVersion'] != 3 ||
        data['groups'] is! List ||
        data['services'] is! List) {
      throw const FormatException();
    }
    return data;
  } catch (_) {
    throw const FormatException('Invalid or unsupported backup.');
  }
}

bool isTwoFasEncrypted(Uint8List bytes) {
  final data = _readTwoFas(bytes);
  final encrypted = data['servicesEncrypted'];
  if (encrypted == null) return false;
  if (encrypted is! String ||
      encrypted.isEmpty ||
      (data['services'] as List).isNotEmpty) {
    throw const FormatException('Invalid backup.');
  }
  return true;
}

Future<LegacyImport> parseTwoFasBackup(
  Uint8List bytes, {
  String? password,
}) async {
  final data = _readTwoFas(bytes);
  dynamic services = data['services'];
  if (isTwoFasEncrypted(bytes)) {
    if (password == null || password.isEmpty || password.length > 1024) {
      throw const FormatException('Password required.');
    }
    try {
      final parts = (data['servicesEncrypted'] as String).split(':');
      if (parts.length != 3) throw const FormatException();
      final ciphertext = base64Decode(parts[0]);
      final salt = base64Decode(parts[1]);
      final nonce = base64Decode(parts[2]);
      if (ciphertext.length < 16 || salt.length != 256 || nonce.length != 12) {
        throw const FormatException();
      }
      final key = await deriveBackupKey(password, salt, 10000);
      final cipher = enc.Encrypter(
        enc.AES(enc.Key(key), mode: enc.AESMode.gcm),
      );
      final plaintext = cipher.decryptBytes(
        enc.Encrypted(ciphertext),
        iv: enc.IV(nonce),
      );
      services = jsonDecode(utf8.decode(plaintext));
    } catch (_) {
      throw const FormatException('Incorrect password or damaged backup.');
    }
  }
  try {
    final groups = data['groups'] as List;
    if (groups.length > 1000 ||
        services is! List ||
        services.isEmpty ||
        services.length > 10000) {
      throw const FormatException();
    }
    final names = <String>{};
    final groupNames = <String, String>{};
    final categories = <AccountCategory>[];
    for (final group in groups) {
      if (group is! Map<String, dynamic> ||
          group['id'] is! String ||
          (group['id'] as String).isEmpty ||
          group['name'] is! String) {
        throw const FormatException();
      }
      final id = group['id'] as String;
      final name = group['name'] as String;
      if (groupNames.containsKey(id) ||
          !names.add(name) ||
          validateCategoryName(name) != name) {
        throw const FormatException();
      }
      groupNames[id] = name;
      categories.add(AccountCategory(name: name));
    }
    validateCategories(categories);
    final accounts = <OtpAccount>[];
    final keys = <(String, String)>{};
    final memberships = <(String, String), List<String>>{};
    for (final service in services) {
      if (service is! Map<String, dynamic> ||
          service['name'] is! String ||
          service['secret'] is! String ||
          service['otp'] is! Map<String, dynamic>) {
        throw const FormatException();
      }
      final otp = service['otp'] as Map<String, dynamic>;
      final type = switch (otp['tokenType']) {
        'TOTP' => 'totp',
        'HOTP' => 'hotp',
        'STEAM' => 'steam',
        _ => throw const FormatException(),
      };
      final algorithm = switch (otp['algorithm']) {
        null || 'SHA1' => 'sha1',
        'SHA256' => 'sha256',
        'SHA512' => 'sha512',
        _ => throw const FormatException(),
      };
      final issuer = otp['issuer'];
      final username = otp['account'];
      final digits = otp['digits'] ?? (type == 'steam' ? 5 : 6);
      final period = otp['period'] ?? 30;
      final counter = otp['counter'] ?? 0;
      if ((issuer != null && issuer is! String) ||
          (username != null && username is! String) ||
          digits is! int ||
          period is! int ||
          counter is! int) {
        throw const FormatException();
      }
      final name = service['name'] as String;
      final actualIssuer = issuer is String && issuer.trim().isNotEmpty
          ? issuer
          : username is String && username.trim().isNotEmpty
          ? username
          : name;
      final actualAccount = username is String && username.trim().isNotEmpty
          ? username
          : name;
      final secret = (service['secret'] as String)
          .replaceAll(RegExp(r'\s+'), '')
          .toUpperCase();
      final account = OtpAccount(
        type: type,
        issuer: actualIssuer,
        account: actualAccount,
        secret: secret,
        algorithm: algorithm,
        digits: digits,
        period: period,
        counter: counter,
      );
      account.validate();
      if (type == 'steam' && algorithm != 'sha1') throw const FormatException();
      final decoded = base32.decode(secret);
      if (decoded.isEmpty ||
          base32.encode(decoded).replaceAll('=', '') !=
              secret.replaceAll('=', '')) {
        throw const FormatException();
      }
      final key = (account.issuer, account.account);
      if (!keys.add(key)) throw const FormatException();
      final groupId = service['groupId'];
      if (groupId != null &&
          (groupId is! String || !groupNames.containsKey(groupId))) {
        throw const FormatException();
      }
      accounts.add(account);
      memberships[key] = groupId == null ? [] : [groupNames[groupId]!];
    }
    return (
      accounts: accounts,
      categories: categories,
      memberships: memberships,
    );
  } catch (_) {
    throw const FormatException('Invalid or unsupported backup contents.');
  }
}
