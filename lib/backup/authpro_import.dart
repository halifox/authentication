import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/legacy_import.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/category.dart';
import 'package:authentication/storage/icon_data.dart';
import 'package:authentication/storage/key_derivation.dart'
    if (dart.library.js_interop) 'package:authentication/storage/key_derivation_web.dart';
import 'package:base32/base32.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart' show compute;
import 'package:pointycastle/export.dart' as pc;

const _strong = [
  65,
  85,
  84,
  72,
  69,
  78,
  84,
  73,
  67,
  65,
  84,
  79,
  82,
  80,
  82,
  79,
];
const _legacy = [
  65,
  117,
  116,
  104,
  101,
  110,
  116,
  105,
  99,
  97,
  116,
  111,
  114,
  80,
  114,
  111,
];

enum AuthproEncryption { none, strong, legacy }

AuthproEncryption authproEncryption(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > maxBackupBytes) {
    throw const FormatException('Invalid backup size.');
  }
  bool starts(List<int> header) =>
      bytes.length >= header.length &&
      List.generate(
        header.length,
        (i) => bytes[i] == header[i],
      ).every((v) => v);
  if (starts(_strong)) return AuthproEncryption.strong;
  if (starts(_legacy)) return AuthproEncryption.legacy;
  return AuthproEncryption.none;
}

Uint8List _argon(List<Object> args) {
  final generator = pc.Argon2BytesGenerator()
    ..init(
      pc.Argon2Parameters(
        pc.Argon2Parameters.ARGON2_id,
        args[1] as Uint8List,
        desiredKeyLength: 32,
        iterations: 3,
        memory: 65536,
        lanes: 4,
        version: pc.Argon2Parameters.ARGON2_VERSION_13,
      ),
    );
  return generator.process(Uint8List.fromList(utf8.encode(args[0] as String)));
}

Future<Uint8List> decryptAuthpro(Uint8List bytes, {String? password}) async {
  final kind = authproEncryption(bytes);
  if (kind == AuthproEncryption.none) return bytes;
  if (password == null || password.isEmpty || password.length > 1024) {
    throw const FormatException('Password required.');
  }
  try {
    if (kind == AuthproEncryption.strong) {
      if (bytes.length < 60) throw const FormatException();
      final key = await compute(_argon, [password, bytes.sublist(16, 32)]);
      final cipher = enc.Encrypter(
        enc.AES(enc.Key(key), mode: enc.AESMode.gcm),
      );
      return Uint8List.fromList(
        cipher.decryptBytes(
          enc.Encrypted(bytes.sublist(44)),
          iv: enc.IV(bytes.sublist(32, 44)),
        ),
      );
    }
    if (bytes.length < 68 || (bytes.length - 52) % 16 != 0) {
      throw const FormatException();
    }
    final key = await derivePbkdf2Key(
      password,
      bytes.sublist(16, 36),
      64000,
      sha1: true,
    );
    final cipher = enc.Encrypter(enc.AES(enc.Key(key), mode: enc.AESMode.cbc));
    return Uint8List.fromList(
      cipher.decryptBytes(
        enc.Encrypted(bytes.sublist(52)),
        iv: enc.IV(bytes.sublist(36, 52)),
      ),
    );
  } catch (_) {
    throw const FormatException('Incorrect password or damaged backup.');
  }
}

/// Parses plaintext after optional decryption.
LegacyImport parseAuthpro(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > maxBackupBytes) {
    throw const FormatException('Invalid backup size.');
  }
  try {
    final data = jsonDecode(utf8.decode(bytes));
    if (data is! Map<String, dynamic> || data['Authenticators'] is! List) {
      throw const FormatException();
    }
    final entries = data['Authenticators'] as List;
    final groups = data['Categories'] ?? [];
    final links = data['AuthenticatorCategories'] ?? [];
    final icons = data['CustomIcons'] ?? [];
    if (entries.isEmpty ||
        entries.length > 10000 ||
        groups is! List ||
        groups.length > 1000 ||
        links is! List ||
        links.length > 100000 ||
        icons is! List ||
        icons.length > 1000) {
      throw const FormatException();
    }
    final customIcons = <String, String>{};
    for (final icon in icons) {
      if (icon is! Map<String, dynamic> ||
          icon['Id'] is! String ||
          icon['Data'] is! String) {
        throw const FormatException();
      }
      final id = icon['Id'] as String;
      final data = icon['Data'] as String;
      if (id.isEmpty ||
          id.length > 100 ||
          id.startsWith('@') ||
          customIcons.containsKey(id) ||
          data.length > maxBackupBytes * 2) {
        throw const FormatException();
      }
      customIcons[id] = makeCustomIcon(base64Decode(data));
    }
    final groupNames = <String, String>{};
    final groupOrder = <(int, int, String)>[];
    final names = <String>{};
    for (final group in groups) {
      if (group is! Map<String, dynamic> ||
          group['Id'] is! String ||
          (group['Id'] as String).isEmpty ||
          group['Name'] is! String ||
          group['Ranking'] is! int) {
        throw const FormatException();
      }
      final id = group['Id'] as String;
      final name = group['Name'] as String;
      if (validateCategoryName(name) != name ||
          !names.add(name) ||
          groupNames.containsKey(id)) {
        throw const FormatException();
      }
      groupNames[id] = name;
      groupOrder.add((group['Ranking'] as int, groupOrder.length, name));
    }
    groupOrder.sort((a, b) {
      final order = a.$1.compareTo(b.$1);
      return order == 0 ? a.$2.compareTo(b.$2) : order;
    });
    final categories = [
      for (final group in groupOrder) AccountCategory(name: group.$3),
    ];
    validateCategories(categories);
    final accounts = <(int, int, OtpAccount)>[];
    final keys = <(String, String)>{};
    final secrets = <String, (String, String)>{};
    final memberships = <(String, String), List<String>>{};
    for (final item in entries) {
      if (item is! Map<String, dynamic> ||
          item['Type'] is! int ||
          item['Issuer'] is! String ||
          item['Secret'] is! String ||
          item['Algorithm'] is! int ||
          item['Digits'] is! int ||
          item['Period'] is! int ||
          item['Counter'] is! int ||
          item['Ranking'] is! int ||
          (item['Username'] != null && item['Username'] is! String) ||
          (item['Pin'] != null && item['Pin'] is! String) ||
          (item['CopyCount'] != null && item['CopyCount'] is! int) ||
          (item['Icon'] != null && item['Icon'] is! String)) {
        throw const FormatException();
      }
      final type = switch (item['Type']) {
        1 => 'hotp',
        2 => 'totp',
        3 => 'motp',
        4 => 'steam',
        5 => 'yandex',
        _ => throw const FormatException(),
      };
      final algorithm = switch (item['Algorithm']) {
        0 => 'sha1',
        1 => 'sha256',
        2 => 'sha512',
        _ => throw const FormatException(),
      };
      final issuer = item['Issuer'] as String;
      final username = item['Username'] as String?;
      final secret = item['Secret'] as String;
      final period = item['Period'] as int;
      if (period <= 0 ||
          (type == 'steam' || type == 'yandex') && period != 30 ||
          type == 'motp' && period != 10) {
        throw const FormatException();
      }
      final sourceIcon = item['Icon'] as String?;
      String? customIcon;
      if (sourceIcon != null && sourceIcon.startsWith('@')) {
        customIcon = customIcons[sourceIcon.substring(1)];
        if (customIcon == null) throw const FormatException();
      }
      final account = OtpAccount(
        type: type,
        issuer: issuer,
        account: username == null || username.trim().isEmpty
            ? issuer
            : username,
        secret: secret,
        algorithm: algorithm,
        digits: switch (type) {
          'steam' => 5,
          'motp' => 6,
          'yandex' => 8,
          _ => item['Digits'] as int,
        },
        period: period,
        counter: item['Counter'] as int,
        pin: item['Pin'] as String? ?? '',
        copyCount: item['CopyCount'] as int? ?? 0,
        icon: customIcon ?? 'assets/icons/passkey.svg',
      );
      account.validate();
      if (type != 'motp') {
        final decoded = base32.decode(secret);
        if (decoded.isEmpty ||
            base32.encode(decoded).replaceAll('=', '') !=
                secret.replaceAll('=', '')) {
          throw const FormatException();
        }
      }
      final key = (account.issuer, account.account);
      if (!keys.add(key) || secrets.containsKey(secret)) {
        throw const FormatException();
      }
      secrets[secret] = key;
      memberships[key] = [];
      accounts.add((item['Ranking'] as int, accounts.length, account));
    }
    for (final link in links) {
      if (link is! Map<String, dynamic> ||
          link['CategoryId'] is! String ||
          link['AuthenticatorSecret'] is! String ||
          link['Ranking'] is! int) {
        throw const FormatException();
      }
      final name = groupNames[link['CategoryId']];
      final key = secrets[link['AuthenticatorSecret']];
      if (name == null || key == null || memberships[key]!.contains(name)) {
        throw const FormatException();
      }
      memberships[key]!.add(name);
    }
    accounts.sort((a, b) {
      final order = a.$1.compareTo(b.$1);
      return order == 0 ? a.$2.compareTo(b.$2) : order;
    });
    return (
      accounts: [for (final a in accounts) a.$3],
      categories: categories,
      memberships: memberships,
    );
  } catch (_) {
    throw const FormatException('Invalid or unsupported backup contents.');
  }
}
