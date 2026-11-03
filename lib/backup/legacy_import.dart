import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/category.dart';
import 'package:authentication/storage/key_derivation.dart'
    if (dart.library.js_interop) 'package:authentication/storage/key_derivation_web.dart';
import 'package:base32/base32.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;

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
        key = await derivePbkdf2Key(
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

LegacyImport parseTokenListBackup(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > maxBackupBytes) {
    throw const FormatException('Invalid backup size.');
  }
  try {
    final data = jsonDecode(utf8.decode(bytes));
    if (data is! Map<String, dynamic> ||
        data['tokens'] is! List ||
        data['tokenOrder'] is! List) {
      throw const FormatException();
    }
    final tokens = data['tokens'] as List;
    final order = data['tokenOrder'] as List;
    if (tokens.isEmpty ||
        tokens.length > 10000 ||
        tokens.length != order.length ||
        order.any((value) => value is! String)) {
      throw const FormatException();
    }
    final indexed = <String, Map<String, dynamic>>{};
    for (final item in tokens) {
      if (item is! Map<String, dynamic>) throw const FormatException();
      final label = item['label'];
      final internal = item['issuerInt'];
      final external = item['issuerExt'];
      if (label is! String ||
          (internal != null && internal is! String) ||
          (external != null && external is! String)) {
        throw const FormatException();
      }
      final issuerId = internal is String && internal.isNotEmpty
          ? internal
          : external is String && external.isNotEmpty
          ? external
          : null;
      final id = issuerId == null ? label : '$issuerId:$label';
      if (indexed.containsKey(id)) throw const FormatException();
      indexed[id] = item;
    }
    final accounts = <OtpAccount>[];
    final categories = <String>{};
    final memberships = <(String, String), List<String>>{};
    final seenOrder = <String>{};
    final seenAccounts = <(String, String)>{};
    for (final id in order.cast<String>()) {
      if (!seenOrder.add(id)) throw const FormatException();
      final item = indexed[id];
      if (item == null) throw const FormatException();
      final altIssuer = item['issuerAlt'];
      final external = item['issuerExt'];
      final internal = item['issuerInt'];
      final altLabel = item['labelAlt'];
      if ((altIssuer != null && altIssuer is! String) ||
          (altLabel != null && altLabel is! String)) {
        throw const FormatException();
      }
      final issuer = altIssuer is String && altIssuer.isNotEmpty
          ? altIssuer
          : external is String && external.isNotEmpty
          ? external
          : internal is String
          ? internal
          : '';
      final label = altLabel is String ? altLabel : item['label'] as String;
      final typeValue = item['type'];
      final algorithm = item['algo'] ?? 'SHA1';
      final secretBytes = item['secret'];
      final digits = item['digits'];
      final counter = item['counter'] ?? 0;
      final period = item['period'] ?? 0;
      if (typeValue is! String ||
          algorithm is! String ||
          secretBytes is! List ||
          secretBytes.isEmpty ||
          digits is! int ||
          counter is! int ||
          period is! int ||
          secretBytes.any(
            (byte) => byte is! int || byte < -128 || byte > 255,
          )) {
        throw const FormatException();
      }
      if (period <= 0) throw const FormatException();
      var type = typeValue.toLowerCase();
      if (!const ['totp', 'hotp'].contains(type)) throw const FormatException();
      if (issuer == 'Steam') {
        if (type != 'totp' || algorithm.toLowerCase() != 'sha1') {
          throw const FormatException();
        }
        type = 'steam';
      }
      final account = OtpAccount(
        type: type,
        issuer: issuer,
        account: label,
        secret: base32.encode(
          Uint8List.fromList(
            secretBytes.cast<int>().map((byte) => byte & 255).toList(),
          ),
        ),
        algorithm: algorithm.toLowerCase(),
        digits: digits,
        counter: counter,
        period: period,
      );
      account.validate();
      if (!seenAccounts.add((issuer, label))) throw const FormatException();
      final category = item['category'];
      if (category != null && category is! String) {
        throw const FormatException();
      }
      final names = <String>[];
      if (category is String && category.isNotEmpty) {
        if (validateCategoryName(category) != category) {
          throw const FormatException();
        }
        categories.add(category);
        names.add(category);
      }
      accounts.add(account);
      memberships[(issuer, label)] = names;
    }
    final categoryList = [
      for (final name in categories) AccountCategory(name: name),
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

({LegacyImport document, int skipped}) parseVaultBackup(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > maxBackupBytes) {
    throw const FormatException('Invalid backup size.');
  }
  try {
    final data = jsonDecode(utf8.decode(bytes));
    if (data is! Map<String, dynamic> ||
        data['encrypted'] != false ||
        data['items'] is! List) {
      throw const FormatException();
    }
    final items = data['items'] as List;
    if (items.isEmpty || items.length > 10000) throw const FormatException();
    final folderValues = data['folders'] ?? const [];
    if (folderValues is! List || folderValues.length > 1000) {
      throw const FormatException();
    }
    final folders = <String, String>{};
    for (final folder in folderValues) {
      if (folder is! Map<String, dynamic> ||
          folder['id'] is! String ||
          folder['name'] is! String) {
        throw const FormatException();
      }
      final id = folder['id'] as String;
      final name = folder['name'] as String;
      if (id.isEmpty ||
          folders.containsKey(id) ||
          validateCategoryName(name) != name) {
        throw const FormatException();
      }
      folders[id] = name;
    }
    final accounts = <OtpAccount>[];
    final categories = <String>{};
    final memberships = <(String, String), List<String>>{};
    final keys = <(String, String)>{};
    var skipped = 0;
    for (final item in items) {
      if (item is! Map<String, dynamic> || item['type'] is! int) {
        throw const FormatException();
      }
      if (item['type'] != 1) {
        skipped++;
        continue;
      }
      final login = item['login'];
      if (login is! Map<String, dynamic>) throw const FormatException();
      final otp = login['totp'];
      if (otp == null || otp == '') {
        skipped++;
        continue;
      }
      if (otp is! String ||
          item['name'] is! String ||
          (login['username'] != null && login['username'] is! String)) {
        throw const FormatException();
      }
      if (otp.toLowerCase().startsWith('otpauth:') &&
          Uri.parse(otp).queryParametersAll.values
              .any((values) => values.length != 1)) {
        throw const FormatException();
      }
      final name = item['name'] as String;
      final username = login['username'] as String?;
      final account = otp.toLowerCase().startsWith('otpauth:')
          ? parseOtpUri(otp)
          : otp.contains('://')
          ? (throw const FormatException())
          : OtpAccount(
              type: 'totp',
              issuer: name,
              account: username == null || username.trim().isEmpty
                  ? name
                  : username,
              secret: otp.trim().replaceAll(RegExp(r'\s+'), '').toUpperCase(),
            );
      final resolved = account.copyWith(
        issuer: account.issuer.trim().isEmpty ? name : account.issuer,
        account: account.account.trim().isEmpty
            ? (username == null || username.trim().isEmpty ? name : username)
            : account.account,
      );
      if (resolved.type.toLowerCase() != 'totp') throw const FormatException();
      resolved.validate();
      if (!keys.add((resolved.issuer, resolved.account))) {
        throw const FormatException();
      }
      final folderId = item['folderId'];
      if (folderId != null && folderId is! String) {
        throw const FormatException();
      }
      final names = <String>[];
      if (folderId is String) {
        final name = folders[folderId];
        if (name == null) throw const FormatException();
        names.add(name);
        categories.add(name);
      }
      accounts.add(resolved);
      memberships[(resolved.issuer, resolved.account)] = names;
    }
    if (accounts.isEmpty) throw const FormatException();
    final categoryList = [
      for (final name in categories) AccountCategory(name: name),
    ];
    validateCategories(categoryList);
    return (
      document: (
        accounts: accounts,
        categories: categoryList,
        memberships: memberships,
      ),
      skipped: skipped,
    );
  } catch (_) {
    throw const FormatException('Invalid or unsupported backup contents.');
  }
}
