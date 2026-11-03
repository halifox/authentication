import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/legacy_import.dart';
import 'package:authentication/otp/account.dart';
import 'package:flutter/foundation.dart' show compute;

bool isWinAuthZip(Uint8List bytes) =>
    bytes.length >= 4 &&
    bytes[0] == 0x50 &&
    bytes[1] == 0x4b &&
    bytes[2] == 0x03 &&
    bytes[3] == 0x04;

LegacyImport parseWinAuthBackup(Uint8List bytes, {String? password}) {
  if (bytes.isEmpty || bytes.length > maxBackupBytes) {
    throw const FormatException('Invalid backup size.');
  }
  try {
    var plaintext = bytes;
    if (isWinAuthZip(bytes)) {
      if (password == null || password.isEmpty || password.length > 1024) {
        throw const FormatException();
      }
      final headers = ZipDirectory()
          .headers(InputMemoryStream(bytes), verify: true, files: false)
          .take(2)
          .toList();
      if (headers.length != 1) throw const FormatException();
      final header = headers.single;
      final mode = header.externalFileAttributes >> 16;
      if (header.uncompressedSize <= 0 ||
          header.uncompressedSize > maxBackupBytes ||
          header.compressedSize > maxBackupBytes ||
          header.filename.endsWith('/') ||
          header.filename.endsWith('\\') ||
          ((header.versionMadeBy >> 8) == 3 && (mode & 0xf000) == 0xa000)) {
        throw const FormatException();
      }
      final archive = ZipDecoder().decodeBytes(
        bytes,
        password: password,
        verify: true,
        throwOnError: true,
      );
      if (archive.files.length != 1 || !archive.files.single.isFile) {
        throw const FormatException();
      }
      final content = archive.files.single.readBytes();
      if (content == null || content.length != header.uncompressedSize) {
        throw const FormatException();
      }
      plaintext = content;
    }
    final lines = utf8
        .decode(plaintext)
        .split(RegExp(r'\r?\n'))
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .toList();
    if (lines.isEmpty || lines.length > 10000) throw const FormatException();
    final accounts = <OtpAccount>[];
    final keys = <(String, String)>{};
    final memberships = <(String, String), List<String>>{};
    for (final line in lines) {
      final uri = Uri.parse(line);
      if (uri.scheme.toLowerCase() != 'otpauth' ||
          uri.queryParametersAll.values.any((values) => values.length != 1)) {
        throw const FormatException();
      }
      var account = parseOtpUri(line, detectSteam: true);
      if (account.issuer.trim().isEmpty && account.account.trim().isNotEmpty) {
        account = account.copyWith(issuer: account.account);
      }
      if (account.account.trim().isEmpty && account.issuer.trim().isNotEmpty) {
        account = account.copyWith(account: account.issuer);
      }
      account.validate();
      final key = (account.issuer, account.account);
      if (!keys.add(key)) throw const FormatException();
      accounts.add(account);
      memberships[key] = [];
    }
    return (accounts: accounts, categories: [], memberships: memberships);
  } catch (_) {
    throw const FormatException('Invalid, unsupported, or damaged backup.');
  }
}

LegacyImport _parseWinAuthInBackground((Uint8List, String?) input) =>
    parseWinAuthBackup(input.$1, password: input.$2);

Future<LegacyImport> parseWinAuthBackupAsync(
  Uint8List bytes, {
  String? password,
}) => compute(_parseWinAuthInBackground, (bytes, password));
