import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/legacy_import.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/category.dart';
import 'package:base32/base32.dart';

LegacyImport parseLastPassBackup(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > maxBackupBytes) {
    throw const FormatException('Invalid backup size.');
  }
  try {
    final data = jsonDecode(utf8.decode(bytes));
    if (data is! Map<String, dynamic> ||
        data['version'] != 3 ||
        data['accounts'] is! List ||
        data['folders'] is! List) {
      throw const FormatException();
    }
    final entries = data['accounts'] as List;
    final folders = data['folders'] as List;
    if (entries.isEmpty || entries.length > 10000 || folders.length > 1001) {
      throw const FormatException();
    }
    final groups = <int, String>{};
    final names = <String>{};
    final categories = <AccountCategory>[];
    final ids = <int>{};
    for (final folder in folders) {
      if (folder is! Map<String, dynamic> ||
          folder['id'] is! int ||
          (folder['id'] as int) < 0 ||
          !ids.add(folder['id'] as int) ||
          folder['name'] is! String) {
        throw const FormatException();
      }
      final id = folder['id'] as int;
      if (id == 0) continue;
      final name = folder['name'] as String;
      if (validateCategoryName(name) != name || !names.add(name)) {
        throw const FormatException();
      }
      groups[id] = name;
      categories.add(AccountCategory(name: name));
    }
    validateCategories(categories);
    final accounts = <OtpAccount>[];
    final keys = <(String, String)>{};
    final memberships = <(String, String), List<String>>{};
    for (final entry in entries) {
      if (entry is! Map<String, dynamic> ||
          entry['issuerName'] is! String ||
          entry['userName'] is! String ||
          entry['secret'] is! String ||
          entry['digits'] is! int ||
          entry['timeStep'] is! int ||
          entry['folderData'] is! Map<String, dynamic>) {
        throw const FormatException();
      }
      final folder = entry['folderData'] as Map<String, dynamic>;
      if (folder['folderId'] is! int ||
          folder['position'] is! int ||
          (folder['folderId'] as int) < 0 ||
          (folder['position'] as int) < 0) {
        throw const FormatException();
      }
      final groupId = folder['folderId'] as int;
      if (groupId != 0 && !groups.containsKey(groupId)) {
        throw const FormatException();
      }
      final algorithm = switch (entry['algorithm']) {
        'SHA1' => 'sha1',
        'SHA256' => 'sha256',
        'SHA512' => 'sha512',
        _ => throw const FormatException(),
      };
      final issuer = entry['issuerName'] as String;
      final username = entry['userName'] as String;
      final effectiveIssuer = issuer.trim().isEmpty ? username : issuer;
      final effectiveUsername = username.trim().isEmpty
          ? effectiveIssuer
          : username;
      final secret = (entry['secret'] as String)
          .replaceAll(RegExp(r'\s+'), '')
          .toUpperCase();
      final account = OtpAccount(
        type: 'totp',
        issuer: effectiveIssuer,
        account: effectiveUsername,
        secret: secret,
        algorithm: algorithm,
        digits: entry['digits'] as int,
        period: entry['timeStep'] as int,
      );
      account.validate();
      final decoded = base32.decode(secret);
      if (decoded.isEmpty ||
          base32.encode(decoded).replaceAll('=', '') !=
              secret.replaceAll('=', '')) {
        throw const FormatException();
      }
      final key = (account.issuer, account.account);
      if (!keys.add(key)) throw const FormatException();
      accounts.add(account);
      memberships[key] = groupId == 0 ? [] : [groups[groupId]!];
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
