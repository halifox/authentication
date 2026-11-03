import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/legacy_import.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/category.dart';
import 'package:crypto/crypto.dart' as hash;
import 'package:cryptography/cryptography.dart';
import 'package:cryptography/dart.dart';
import 'package:flutter/foundation.dart' show compute;
import 'package:pointycastle/export.dart' as pc;
import 'package:xml/xml.dart';

/// Reads an already authenticated and decompressed KDBX 4 payload.
Future<LegacyImport> parseKdbxPayloadAsync(Uint8List bytes) =>
    compute(parseKdbxPayload, bytes);

LegacyImport parseKdbxPayload(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > maxBackupBytes) {
    throw const FormatException();
  }
  final data = ByteData.sublistView(bytes);
  var offset = 0;
  int? algorithm;
  Uint8List? key;
  while (true) {
    if (offset + 5 > bytes.length) throw const FormatException();
    final id = bytes[offset];
    final size = data.getUint32(offset + 1, Endian.little);
    offset += 5;
    if (size > bytes.length - offset) throw const FormatException();
    final value = Uint8List.sublistView(bytes, offset, offset + size);
    offset += size;
    if (id == 0) {
      if (size != 0) throw const FormatException();
      break;
    }
    if (id == 1) {
      if (algorithm != null || size != 4) throw const FormatException();
      algorithm = ByteData.sublistView(value).getUint32(0, Endian.little);
    } else if (id == 2) {
      if (key != null || size != 64) throw const FormatException();
      key = Uint8List.fromList(value);
    } else if (id != 3) {
      throw const FormatException();
    }
  }
  if (algorithm == null || key == null) throw const FormatException();
  late final List<int> Function(List<int>) decrypt;
  if (algorithm == 3) {
    final digest = hash.sha512.convert(key).bytes;
    final state =
        const DartChacha20(macAlgorithm: MacAlgorithm.empty).newState()
          ..initializeSync(
            isEncrypting: true,
            secretKey: SecretKeyData(digest.sublist(0, 32)),
            nonce: digest.sublist(32, 44),
          );
    decrypt = state.convertChunkSync;
  } else if (algorithm == 2) {
    final digest = Uint8List.fromList(hash.sha256.convert(key).bytes);
    final state = pc.Salsa20Engine()
      ..init(
        false,
        pc.ParametersWithIV(
          pc.KeyParameter(digest),
          Uint8List.fromList([0xe8, 0x30, 0x09, 0x4b, 0x97, 0x20, 0x5d, 0x2a]),
        ),
      );
    decrypt = (value) {
      final result = Uint8List(value.length);
      state.processBytes(Uint8List.fromList(value), 0, value.length, result, 0);
      return result;
    };
  } else {
    throw const FormatException();
  }
  final xml = utf8.decode(Uint8List.sublistView(bytes, offset));
  if (RegExp(r'<!DOCTYPE', caseSensitive: false).hasMatch(xml)) {
    throw const FormatException();
  }
  var tags = 0;
  for (final code in xml.codeUnits) {
    if (code == 60 && ++tags > 100000) throw const FormatException();
  }
  final document = XmlDocument.parse(xml);
  if (document.children.any((node) => node is XmlDoctype)) {
    throw const FormatException();
  }
  final protectedValues = <XmlElement, String>{};
  for (final element in document.descendants.whereType<XmlElement>()) {
    if (element.name.local == 'Value' &&
        element.getAttribute('Protected') == 'True') {
      protectedValues[element] = utf8.decode(
        decrypt(base64Decode(element.innerText)),
      );
    }
  }
  final recycle = document
      .findAllElements('RecycleBinUUID')
      .firstOrNull
      ?.innerText;
  final root = document.rootElement.getElement('Root')?.getElement('Group');
  if (root == null) throw const FormatException();
  final accounts = <OtpAccount>[];
  final categories = <AccountCategory>[];
  final names = <String>{};
  final memberships = <(String, String), List<String>>{};
  final seen = <(String, String)>{};
  void visit(XmlElement group, List<String> parents, int depth) {
    if (depth > 100) throw const FormatException();
    if (group.getElement('UUID')?.innerText == recycle && recycle != null) {
      return;
    }
    final name = group.getElement('Name')?.innerText.trim() ?? '';
    final path = depth == 0
        ? parents
        : [...parents, validateCategoryName(name)];
    for (final entry in group.childElements.where(
      (e) => e.name.local == 'Entry',
    )) {
      String? uri;
      for (final field in entry.childElements.where(
        (e) => e.name.local == 'String',
      )) {
        if (field.getElement('Key')?.innerText != 'otp') continue;
        final value = field.getElement('Value');
        if (uri != null || value == null) throw const FormatException();
        uri = protectedValues[value] ?? value.innerText;
      }
      if (uri == null || uri.isEmpty) continue;
      final account = parseOtpUri(uri, detectSteam: true)..validate();
      final identity = (account.issuer, account.account);
      if (!seen.add(identity) || accounts.length >= 10000) {
        throw const FormatException();
      }
      accounts.add(account);
      for (final category in path) {
        if (names.add(category)) {
          categories.add(
            AccountCategory(name: category, sortOrder: categories.length),
          );
        }
      }
      memberships[identity] = path.toSet().toList();
    }
    for (final child in group.childElements.where(
      (e) => e.name.local == 'Group',
    )) {
      visit(child, path, depth + 1);
    }
  }

  visit(root, [], 0);
  if (accounts.isEmpty) throw const FormatException();
  validateCategories(categories);
  return (accounts: accounts, categories: categories, memberships: memberships);
}
