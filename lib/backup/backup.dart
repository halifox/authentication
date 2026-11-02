import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/otp/account.dart';

import 'package:encrypt/encrypt.dart' as enc;

import 'backup_key.dart' if (dart.library.js_interop) 'backup_key_web.dart';

const _iterations = 600000;
const maxBackupBytes = 10 * 1024 * 1024;

/// Versioned file format. Password protected files use PBKDF2-SHA256 and AES-256-GCM.
class Backup {
  static Future<Uint8List> encode(
    List<Map<String, Object>> entries,
    String? password,
  ) async {
    final payload = utf8.encode(jsonEncode({'entries': entries}));
    final Map<String, Object> envelope = {
      'format': 'authentication-backup',
      'version': 1,
    };
    if (password == null) {
      envelope['encrypted'] = false;
      envelope['entries'] = entries;
    } else {
      if (password.isEmpty)
        throw const FormatException('Password cannot be empty.');
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
    if (bytes.length > maxBackupBytes)
      throw const FormatException('Backup is too large.');
    final data = jsonDecode(utf8.decode(bytes));
    if (data is! Map<String, dynamic> ||
        data['format'] != 'authentication-backup' ||
        data['version'] != 1 ||
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
  ) async {
    final envelope = _envelope(bytes);
    dynamic entries;
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
        if (salt.length != 16 || nonce.length != 12)
          throw const FormatException();
        final key = await deriveBackupKey(password, salt, _iterations);
        final cipher = enc.Encrypter(
          enc.AES(enc.Key(key), mode: enc.AESMode.gcm),
        );
        final plaintext = cipher.decrypt64(
          envelope['ciphertext'] as String,
          iv: enc.IV(nonce),
        );
        entries = (jsonDecode(plaintext) as Map<String, dynamic>)['entries'];
      } catch (_) {
        throw const FormatException('Incorrect password or damaged backup.');
      }
    } else {
      entries = envelope['entries'];
    }
    if (entries is! List ||
        entries.isEmpty ||
        entries.length > 10000 ||
        entries.any(
          (e) =>
              e is! Map ||
              e['uri'] is! String ||
              e['icon'] is! String ||
              e['sortOrder'] is! int ||
              e['createdAt'] is! int,
        )) {
      throw const FormatException('Invalid backup entries.');
    }
    return entries.map((e) => Map<String, Object>.from(e as Map)).toList();
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
      );
      account.validate();
      return account;
    }).toList();

Future<Uint8List> encodeBackupAccounts(
  List<OtpAccount> accounts,
  String? password,
) => Backup.encode(
  accounts
      .map(
        (e) => <String, Object>{
          'uri': e.toOtpUri(),
          'icon': e.icon,
          'sortOrder': e.sortOrder,
          'createdAt': e.createdAt,
        },
      )
      .toList(),
  password,
);

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
