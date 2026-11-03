import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/legacy_import.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/category.dart';
import 'package:base32/base32.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart' show compute;
import 'package:pointycastle/export.dart' as pc;

Map<String, dynamic> _envelope(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > maxBackupBytes) {
    throw const FormatException('Invalid backup size.');
  }
  try {
    final data = jsonDecode(utf8.decode(bytes));
    if (data is! Map<String, dynamic> ||
        data['version'] != 1 ||
        data['header'] is! Map<String, dynamic>) {
      throw const FormatException();
    }
    return data;
  } catch (_) {
    throw const FormatException('Invalid or unsupported backup.');
  }
}

bool isGroupedBackupEncrypted(Uint8List bytes) {
  final envelope = _envelope(bytes);
  final header = envelope['header'] as Map<String, dynamic>;
  if (header['slots'] == null &&
      header['params'] == null &&
      envelope['db'] is Map<String, dynamic>) {
    return false;
  }
  if (header['slots'] is List &&
      header['params'] is Map<String, dynamic> &&
      envelope['db'] is String) {
    return true;
  }
  throw const FormatException('Invalid backup header.');
}

Uint8List _hex(Object? value, int length) {
  if (value is! String ||
      value.length != length * 2 ||
      !RegExp(r'^[0-9a-fA-F]+$').hasMatch(value)) {
    throw const FormatException();
  }
  return Uint8List.fromList([
    for (var i = 0; i < value.length; i += 2)
      int.parse(value.substring(i, i + 2), radix: 16),
  ]);
}

Uint8List _scrypt(List<Object> args) {
  final derivator = pc.Scrypt()
    ..init(pc.ScryptParameters(32768, 8, 1, 32, args[1] as Uint8List));
  return derivator.process(Uint8List.fromList(utf8.encode(args[0] as String)));
}

Uint8List _decrypt(
  Uint8List key,
  Uint8List ciphertext,
  Map<String, dynamic> params,
) {
  final nonce = _hex(params['nonce'], 12);
  final tag = _hex(params['tag'], 16);
  final encrypted = Uint8List.fromList([...ciphertext, ...tag]);
  return Uint8List.fromList(
    enc.Encrypter(enc.AES(enc.Key(key), mode: enc.AESMode.gcm))
        .decryptBytes(enc.Encrypted(encrypted), iv: enc.IV(nonce)),
  );
}

Future<LegacyImport> parseGroupedBackup(
  Uint8List bytes, {
  String? password,
}) async {
  final envelope = _envelope(bytes);
  final encrypted = isGroupedBackupEncrypted(bytes);
  dynamic content = envelope['db'];
  if (encrypted) {
    if (password == null || password.isEmpty || password.length > 1024) {
      throw const FormatException('Password required.');
    }
    try {
      final header = envelope['header'] as Map<String, dynamic>;
      final slots = header['slots'] as List;
      if (slots.isEmpty || slots.length > 8) throw const FormatException();
      if (slots
              .whereType<Map<String, dynamic>>()
              .where((slot) => slot['type'] == 1)
              .length >
          2) {
        throw const FormatException();
      }
      Uint8List? masterKey;
      for (final slot in slots) {
        if (slot is! Map<String, dynamic> || slot['type'] is! int) {
          throw const FormatException();
        }
        if (slot['type'] != 1) continue;
        if (slot['n'] != 32768 ||
            slot['r'] != 8 ||
            slot['p'] != 1 ||
            slot['key_params'] is! Map<String, dynamic>) {
          throw const FormatException();
        }
        final salt = _hex(slot['salt'], 32);
        final wrappedKey = _hex(slot['key'], 32);
        final key = await compute(_scrypt, [password, salt]);
        try {
          masterKey = _decrypt(
            key,
            wrappedKey,
            slot['key_params'] as Map<String, dynamic>,
          );
          break;
        } catch (_) {
          // Try another password slot, if present.
        }
      }
      if (masterKey == null || masterKey.length != 32) {
        throw const FormatException();
      }
      final encryptedData = base64Decode(content as String);
      final plaintext = _decrypt(
        masterKey,
        encryptedData,
        header['params'] as Map<String, dynamic>,
      );
      content = jsonDecode(utf8.decode(plaintext));
    } catch (_) {
      throw const FormatException(
        'Incorrect password or damaged or unsupported backup.',
      );
    }
  }
  try {
    if (content is! Map<String, dynamic> ||
        content['version'] is! int ||
        !const [1, 2, 3].contains(content['version']) ||
        content['entries'] is! List) {
      throw const FormatException();
    }
    final entries = content['entries'] as List;
    if (entries.isEmpty || entries.length > 10000) {
      throw const FormatException();
    }
    final groups = content['groups'] ?? const [];
    if (groups is! List || groups.length > 1000) throw const FormatException();
    final groupNames = <String, String>{};
    final names = <String>{};
    final uuidPattern = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
    );
    for (final group in groups) {
      if (group is! Map<String, dynamic> ||
          group['uuid'] is! String ||
          group['name'] is! String) {
        throw const FormatException();
      }
      final id = (group['uuid'] as String).toLowerCase();
      final name = group['name'] as String;
      if (!uuidPattern.hasMatch(id) ||
          groupNames.containsKey(id) ||
          validateCategoryName(name) != name ||
          !names.add(name)) {
        throw const FormatException();
      }
      groupNames[id] = name;
    }
    final accounts = <OtpAccount>[];
    final memberships = <(String, String), List<String>>{};
    final keys = <(String, String)>{};
    final entryIds = <String>{};
    for (final entry in entries) {
      if (entry is! Map<String, dynamic> ||
          entry['name'] is! String ||
          entry['issuer'] is! String ||
          entry['type'] is! String ||
          entry['info'] is! Map<String, dynamic>) {
        throw const FormatException();
      }
      final entryId = entry['uuid'];
      if (entryId != null &&
          (entryId is! String ||
              !uuidPattern.hasMatch(entryId) ||
              !entryIds.add(entryId.toLowerCase()))) {
        throw const FormatException();
      }
      final info = entry['info'] as Map<String, dynamic>;
      final type = (entry['type'] as String).toLowerCase();
      final secret = info['secret'];
      final algo = info['algo'];
      final digits = info['digits'];
      if (!const ['totp', 'hotp', 'steam', 'motp', 'yandex'].contains(type) ||
          secret is! String ||
          algo is! String ||
          digits is! int) {
        throw const FormatException();
      }
      final period = type == 'hotp' ? 30 : info['period'];
      final counter = type == 'hotp' ? info['counter'] : 0;
      final pin = type == 'motp' || type == 'yandex' ? info['pin'] : '';
      if (period is! int || counter is! int || pin is! String) {
        throw const FormatException();
      }
      var algorithm = algo.toLowerCase();
      var accountSecret = secret.toUpperCase();
      if (type == 'motp') {
        if (algorithm != 'md5' || period != 10 || digits != 6) {
          throw const FormatException();
        }
        accountSecret = base32
            .decode(accountSecret)
            .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
            .join();
        algorithm = 'sha1';
      } else if (type == 'steam') {
        if (algorithm != 'sha1') throw const FormatException();
      } else if (type == 'yandex') {
        if (algorithm != 'sha256' ||
            base32.decode(accountSecret).length != 16) {
          throw const FormatException();
        }
      }
      final account = OtpAccount(
        type: type,
        issuer: entry['issuer'] as String,
        account: entry['name'] as String,
        secret: accountSecret,
        algorithm: algorithm,
        digits: digits,
        period: period,
        counter: counter,
        pin: pin,
      );
      account.validate();
      if (!keys.add((account.issuer, account.account))) {
        throw const FormatException();
      }
      final memberNames = <String>{};
      if (entry.containsKey('groups')) {
        final entryGroups = entry['groups'];
        if (entryGroups is! List ||
            entryGroups.any(
              (id) =>
                  id is! String || !groupNames.containsKey(id.toLowerCase()),
            )) {
          throw const FormatException();
        }
        for (final id in entryGroups.cast<String>()) {
          memberNames.add(groupNames[id.toLowerCase()]!);
        }
      } else if (entry['group'] != null) {
        final name = entry['group'];
        if (name is! String || validateCategoryName(name) != name) {
          throw const FormatException();
        }
        names.add(name);
        memberNames.add(name);
      }
      accounts.add(account);
      memberships[(account.issuer, account.account)] = memberNames.toList();
    }
    final categoryList = [
      for (final name in names) AccountCategory(name: name),
    ];
    validateCategories(categoryList);
    return (
      accounts: accounts,
      categories: categoryList,
      memberships: memberships,
    );
  } catch (_) {
    throw const FormatException('Invalid or unsupported backup contents.');
  }
}
