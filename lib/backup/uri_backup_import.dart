import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/legacy_import.dart';
import 'package:authentication/otp/account.dart';
import 'package:base32/base32.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:flutter/foundation.dart' show compute;
import 'package:pointycastle/export.dart' as pc;

Map<String, dynamic> _readEnvelope(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > maxBackupBytes) {
    throw const FormatException('Invalid backup size.');
  }
  try {
    final data = jsonDecode(utf8.decode(bytes));
    if (data is! Map<String, dynamic> || data['version'] != 1) {
      throw const FormatException();
    }
    return data;
  } catch (_) {
    throw const FormatException('Invalid or unsupported backup.');
  }
}

bool isUriBackupEncrypted(Uint8List bytes) {
  final data = _readEnvelope(bytes);
  if (data['salt'] is String &&
      data['content'] is String &&
      !data.containsKey('entries')) {
    return true;
  }
  if (!data.containsKey('salt') && data['entries'] is List) return false;
  throw const FormatException('Invalid backup envelope.');
}

Uint8List _deriveArgonKey(List<Object> args) {
  final parameters = pc.Argon2Parameters(
    pc.Argon2Parameters.ARGON2_id,
    args[1] as Uint8List,
    desiredKeyLength: 32,
    iterations: 2,
    memory: 19456,
    lanes: 1,
    version: pc.Argon2Parameters.ARGON2_VERSION_13,
  );
  final derivator = pc.Argon2BytesGenerator()..init(parameters);
  return derivator.process(Uint8List.fromList(utf8.encode(args[0] as String)));
}

Future<Uint8List> decryptUriBackup(Uint8List bytes, {String? password}) async {
  if (!isUriBackupEncrypted(bytes)) return bytes;
  if (password == null || password.isEmpty || password.length > 1024) {
    throw const FormatException('Password required.');
  }
  try {
    final data = _readEnvelope(bytes);
    final salt = base64Decode(data['salt'] as String);
    final encrypted = base64Decode(data['content'] as String);
    if (salt.length != 16 || encrypted.length < 28) {
      throw const FormatException();
    }
    final key = await compute(_deriveArgonKey, [password, salt]);
    final cipher = enc.Encrypter(enc.AES(enc.Key(key), mode: enc.AESMode.gcm));
    return Uint8List.fromList(
      cipher.decryptBytes(
        enc.Encrypted(encrypted.sublist(12)),
        iv: enc.IV(encrypted.sublist(0, 12)),
        associatedData: Uint8List.fromList(
          utf8.encode('proton.authenticator.export.v1'),
        ),
      ),
    );
  } catch (_) {
    throw const FormatException('Incorrect password or damaged backup.');
  }
}

LegacyImport parseUriBackup(Uint8List bytes) {
  final data = _readEnvelope(bytes);
  try {
    if (data.containsKey('salt') || data['entries'] is! List) {
      throw const FormatException();
    }
    final entries = data['entries'] as List;
    if (entries.isEmpty || entries.length > 10000) {
      throw const FormatException();
    }
    final accounts = <OtpAccount>[];
    final ids = <String>{};
    final keys = <(String, String)>{};
    final memberships = <(String, String), List<String>>{};
    for (final entry in entries) {
      if (entry is! Map<String, dynamic> ||
          entry['id'] is! String ||
          entry['content'] is! Map<String, dynamic>) {
        throw const FormatException();
      }
      if ((entry['id'] as String).isEmpty || !ids.add(entry['id'] as String)) {
        throw const FormatException();
      }
      final content = entry['content'] as Map<String, dynamic>;
      final uri = content['uri'];
      final type = content['entry_type'];
      final name = content['name'];
      if (uri is! String ||
          type is! String ||
          (name != null && name is! String)) {
        throw const FormatException();
      }
      late OtpAccount account;
      if (type == 'Totp') {
        if (!uri.toLowerCase().startsWith('otpauth:') ||
            Uri.parse(uri).queryParametersAll.values
                .any((values) => values.length != 1)) {
          throw const FormatException();
        }
        final parsed = parseOtpUri(uri);
        final fallback = name is String ? name : '';
        account = parsed.copyWith(
          issuer: parsed.issuer.trim().isEmpty ? fallback : parsed.issuer,
          account: parsed.account.trim().isEmpty ? fallback : parsed.account,
        );
        if (account.type != 'totp') throw const FormatException();
      } else if (type == 'Steam') {
        if (!uri.startsWith('steam://')) throw const FormatException();
        final encoded = uri
            .substring('steam://'.length)
            .replaceFirst(RegExp(r'=+$'), '');
        if (encoded.isEmpty || encoded.contains('?') || encoded.contains('#')) {
          throw const FormatException();
        }
        Uint8List secret;
        if (RegExp(r'^[A-Z2-7]+$').hasMatch(encoded)) {
          secret = base32.decode(encoded);
        } else {
          secret = base64Decode(base64.normalize(encoded));
        }
        if (secret.isEmpty) throw const FormatException();
        account = OtpAccount(
          type: 'steam',
          issuer: 'Steam',
          account: name is String && name.trim().isNotEmpty ? name : 'Steam',
          secret: base32.encode(secret),
          digits: 5,
        );
      } else {
        throw const FormatException();
      }
      account.validate();
      final decodedSecret = base32.decode(account.secret.toUpperCase());
      final canonicalSecret = base32.encode(decodedSecret).replaceAll('=', '');
      if (decodedSecret.isEmpty ||
          account.secret.toUpperCase().replaceAll('=', '') != canonicalSecret) {
        throw const FormatException();
      }
      if (!keys.add((account.issuer, account.account))) {
        throw const FormatException();
      }
      accounts.add(account);
      memberships[(account.issuer, account.account)] = [];
    }
    return (accounts: accounts, categories: [], memberships: memberships);
  } catch (_) {
    throw const FormatException('Invalid or unsupported backup contents.');
  }
}
