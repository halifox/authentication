import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/category.dart';
import 'package:authentication/settings/settings.dart';

import 'package:encrypt/encrypt.dart' as enc;

import 'backup_key.dart' if (dart.library.js_interop) 'backup_key_web.dart';

const _iterations = 600000;
const maxBackupBytes = 10 * 1024 * 1024;

/// Versioned file format. Password protected files use PBKDF2-SHA256 and AES-256-GCM.
class Backup {
  static Future<Uint8List> encode(
    List<Map<String, Object>> entries,
    String? password, {
    Map<String, bool>? settings,
    Map<String, int>? integerSettings,
    bool includeCopyCounts = false,
    List<AccountCategory>? categories,
  }) async {
    if (categories != null && !includeCopyCounts) {
      throw const FormatException(
        'Categories require complete account metadata.',
      );
    }
    final validatedCategories = categories == null
        ? null
        : validateCategories(categories);
    if (validatedCategories != null) {
      validateBackupMemberships(entries, validatedCategories);
    }
    final validatedSettings = settings == null
        ? null
        : validateSettings(settings);
    if (includeCopyCounts && integerSettings == null) {
      throw const FormatException('Copy counts require complete settings.');
    }
    if (integerSettings != null && validatedSettings == null) {
      throw const FormatException('Integer settings require base settings.');
    }
    final validatedIntegers = integerSettings == null
        ? null
        : validateIntegerSettings(integerSettings);
    final contents = <String, Object>{
      'entries': entries,
      'settings': ?validatedSettings,
      'integerSettings': ?validatedIntegers,
      if (validatedCategories != null)
        'categories': [
          for (final category in validatedCategories)
            {
              'name': category.name,
              'sortOrder': category.sortOrder,
              'isDefault': category.isDefault,
            },
        ],
    };
    final payload = utf8.encode(jsonEncode(contents));
    final Map<String, Object> envelope = {
      'format': 'authentication-backup',
      'version': validatedCategories != null
          ? 5
          : includeCopyCounts
          ? 4
          : validatedIntegers != null
          ? 3
          : (validatedSettings == null ? 1 : 2),
    };
    if (password == null) {
      envelope['encrypted'] = false;
      envelope.addAll(contents);
    } else {
      if (password.isEmpty) {
        throw const FormatException('Password cannot be empty.');
      }
      final salt = enc.IV.fromSecureRandom(16);
      final nonce = enc.IV.fromSecureRandom(12);
      final key = await deriveBackupKey(password, salt.bytes, _iterations);
      final cipher = enc.Encrypter(
        enc.AES(enc.Key(key), mode: enc.AESMode.gcm),
      );
      envelope.addAll({
        'encrypted': true,
        'kdf': 'pbkdf2-sha256',
        'iterations': _iterations,
        'salt': salt.base64,
        'nonce': nonce.base64,
        'ciphertext': cipher.encryptBytes(payload, iv: nonce).base64,
      });
    }
    return Uint8List.fromList(utf8.encode(jsonEncode(envelope)));
  }

  static Map<String, dynamic> _envelope(Uint8List bytes) {
    if (bytes.length > maxBackupBytes) {
      throw const FormatException('Backup is too large.');
    }
    final data = jsonDecode(utf8.decode(bytes));
    if (data is! Map<String, dynamic> ||
        data['format'] != 'authentication-backup' ||
        (data['version'] != 1 &&
            data['version'] != 2 &&
            data['version'] != 3 &&
            data['version'] != 4 &&
            data['version'] != 5) ||
        data['encrypted'] is! bool) {
      throw const FormatException('Unsupported backup format.');
    }
    return data;
  }

  static bool isEncrypted(Uint8List bytes) =>
      _envelope(bytes)['encrypted'] as bool;

  static Future<List<Map<String, Object>>> decode(
    Uint8List bytes,
    String? password,
  ) async => (await decodeDocument(bytes, password)).entries;

  static Future<
    ({
      List<Map<String, Object>> entries,
      Map<String, bool>? settings,
      Map<String, int>? integerSettings,
      List<AccountCategory>? categories,
      bool hasCopyCounts,
    })
  >
  decodeDocument(Uint8List bytes, String? password) async {
    final envelope = _envelope(bytes);
    dynamic contents;
    if (envelope['encrypted'] == true) {
      if (password == null ||
          password.isEmpty ||
          envelope['kdf'] != 'pbkdf2-sha256' ||
          envelope['iterations'] != _iterations) {
        throw const FormatException(
          'Invalid password or unsupported encryption.',
        );
      }
      try {
        final salt = base64Decode(envelope['salt'] as String);
        final nonce = base64Decode(envelope['nonce'] as String);
        if (salt.length != 16 || nonce.length != 12) {
          throw const FormatException();
        }
        final key = await deriveBackupKey(password, salt, _iterations);
        final cipher = enc.Encrypter(
          enc.AES(enc.Key(key), mode: enc.AESMode.gcm),
        );
        final plaintext = cipher.decrypt64(
          envelope['ciphertext'] as String,
          iv: enc.IV(nonce),
        );
        contents = jsonDecode(plaintext);
      } catch (_) {
        throw const FormatException('Incorrect password or damaged backup.');
      }
    } else {
      contents = envelope;
    }
    if (contents is! Map) {
      throw const FormatException('Invalid backup contents.');
    }
    final entries = contents['entries'];
    if ((envelope['version'] == 1 && contents.containsKey('settings')) ||
        (envelope['version'] < 3 && contents.containsKey('integerSettings')) ||
        (envelope['version'] < 5 && contents.containsKey('categories'))) {
      throw const FormatException('Invalid backup version.');
    }
    final settings = envelope['version'] >= 2
        ? validateSettings(contents['settings'])
        : null;
    final integerSettings = envelope['version'] >= 3
        ? validateIntegerSettings(contents['integerSettings'])
        : null;
    final categories = envelope['version'] == 5
        ? parseBackupCategories(contents['categories'])
        : null;
    if (entries is! List ||
        (entries.isEmpty && envelope['version'] < 5) ||
        entries.length > 10000 ||
        entries.any(
          (e) =>
              e is! Map ||
              e['uri'] is! String ||
              e['icon'] is! String ||
              e['sortOrder'] is! int ||
              e['createdAt'] is! int ||
              (envelope['version'] < 5 && e.containsKey('categories')) ||
              (envelope['version'] >= 4
                  ? e['copyCount'] is! int || (e['copyCount'] as int) < 0
                  : e.containsKey('copyCount')),
        )) {
      throw const FormatException('Invalid backup entries.');
    }
    final mappedEntries = entries
        .map((e) => Map<String, Object>.from(e as Map))
        .toList();
    if (categories != null) {
      validateBackupMemberships(mappedEntries, categories);
    }
    return (
      entries: mappedEntries,
      settings: settings,
      integerSettings: integerSettings,
      categories: categories,
      hasCopyCounts: (envelope['version'] as int) >= 4,
    );
  }
}

List<AccountCategory> parseBackupCategories(Object? data) {
  if (data is! List || data.length > 1000) {
    throw const FormatException('Invalid categories.');
  }
  final result = <AccountCategory>[];
  for (final item in data) {
    if (item is! Map ||
        item.length != 3 ||
        item['name'] is! String ||
        item['sortOrder'] is! int ||
        item['isDefault'] is! bool) {
      throw const FormatException('Invalid category.');
    }
    result.add(
      AccountCategory(
        name: item['name'] as String,
        sortOrder: item['sortOrder'] as int,
        isDefault: item['isDefault'] as bool,
      ),
    );
  }
  return validateCategories(result);
}

void validateBackupMemberships(
  List<Map<String, Object>> entries,
  List<AccountCategory> categories,
) {
  final validNames = categories.map((category) => category.name).toSet();
  for (final entry in entries) {
    final names = entry['categories'];
    if (names is! List ||
        names.length > 1000 ||
        names.any((name) => name is! String || !validNames.contains(name)) ||
        names.toSet().length != names.length) {
      throw const FormatException('Invalid category membership.');
    }
  }
}

List<OtpAccount> parseBackupAccounts(List<Map<String, Object>> entries) =>
    entries.map((entry) {
      final icon = entry['icon'] as String;
      if (!RegExp(r'^assets/icons/[a-zA-Z0-9_-]+\.svg$').hasMatch(icon)) {
        throw const FormatException('Invalid icon path.');
      }
      final account = parseOtpUri(entry['uri'] as String).copyWith(
        icon: icon,
        sortOrder: entry['sortOrder'] as int,
        createdAt: entry['createdAt'] as int,
        copyCount: entry['copyCount'] as int? ?? 0,
      );
      account.validate();
      return account;
    }).toList();

Future<Uint8List> encodeBackupAccounts(
  List<OtpAccount> accounts,
  String? password, {
  Map<String, bool>? settings,
  Map<String, int>? integerSettings,
  bool includeCopyCounts = false,
  List<AccountCategory>? categories,
  Map<int, List<String>>? memberships,
}) {
  if (categories != null && accounts.isNotEmpty && memberships == null) {
    throw const FormatException('Category memberships are required.');
  }
  return Backup.encode(
    accounts
        .map(
          (e) => <String, Object>{
            'uri': e.toOtpUri(),
            'icon': e.icon,
            'sortOrder': e.sortOrder,
            'createdAt': e.createdAt,
            if (includeCopyCounts) 'copyCount': e.copyCount,
            if (categories != null)
              'categories': memberships?[e.id] ?? <String>[],
          },
        )
        .toList(),
    password,
    settings: settings,
    integerSettings: integerSettings,
    includeCopyCounts: includeCopyCounts,
    categories: categories,
  );
}

Future<
  ({
    List<OtpAccount> accounts,
    Map<String, bool>? settings,
    Map<String, int>? integerSettings,
    bool hasCopyCounts,
    List<AccountCategory>? categories,
    Map<(String, String), List<String>>? memberships,
  })
>
decodeBackupDocument(Uint8List bytes, String? password) async {
  final document = await Backup.decodeDocument(bytes, password);
  return (
    accounts: parseBackupAccounts(document.entries),
    settings: document.settings,
    integerSettings: document.integerSettings,
    hasCopyCounts: document.hasCopyCounts,
    categories: document.categories,
    memberships: document.categories == null
        ? null
        : {
            for (final entry in document.entries)
              (
                parseOtpUri(entry['uri'] as String).issuer,
                parseOtpUri(entry['uri'] as String).account,
              ): (entry['categories'] as List)
                  .cast<String>(),
          },
  );
}

Future<List<OtpAccount>> decodeBackupAccounts(
  Uint8List bytes,
  String? password,
) async => parseBackupAccounts(await Backup.decode(bytes, password));

/// A UTF-8 file containing one OTP URI per non-empty line.
List<OtpAccount> decodeUriList(Uint8List bytes) {
  if (bytes.length > maxBackupBytes) {
    throw const FormatException('File too large.');
  }
  final lines = utf8
      .decode(bytes)
      .split(RegExp(r'\r?\n'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .toList();
  if (lines.isEmpty || lines.length > 10000) {
    throw const FormatException('Invalid URI list.');
  }
  final accounts = lines.map(parseOtpUri).toList();
  for (final account in accounts) {
    account.validate();
  }
  return accounts;
}

Uint8List encodeUriList(List<OtpAccount> accounts) {
  if (accounts.isEmpty || accounts.length > 10000) {
    throw const FormatException('Invalid URI list.');
  }
  for (final account in accounts) {
    account.validate();
  }
  final bytes = Uint8List.fromList(
    utf8.encode('${accounts.map((e) => e.toOtpUri()).join('\n')}\n'),
  );
  if (bytes.length > maxBackupBytes) {
    throw const FormatException('File too large.');
  }
  return bytes;
}
