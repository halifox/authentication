import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/legacy_import.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/category.dart';
import 'package:base32/base32.dart';

/// Reads the unencrypted variant. Encrypted variants must be explicitly rejected.
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
        icons is! List) {
      throw const FormatException();
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
          (item['CopyCount'] != null && item['CopyCount'] is! int)) {
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
