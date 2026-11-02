import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/otp/account.dart';
import 'package:base32/base32.dart';
import 'package:protobuf/protobuf.dart';

const _maxPayloadBytes = 65536;
const _maxBatches = 100;
const _maxAccounts = 10000;

class MigrationBatch {
  const MigrationBatch({
    required this.id,
    required this.size,
    required this.index,
    required this.accounts,
  });
  final int id, size, index;
  final List<OtpAccount> accounts;
}

MigrationBatch parseMigrationUri(String input) {
  try {
    if (input.length > _maxPayloadBytes * 2) throw const FormatException();
    final uri = Uri.parse(input);
    if (uri.scheme.toLowerCase() != 'otpauth-migration' ||
        uri.host.toLowerCase() != 'offline' ||
        uri.path.isNotEmpty ||
        uri.hasFragment ||
        uri.queryParametersAll.length != 1 ||
        uri.queryParametersAll['data']?.length != 1) {
      throw const FormatException();
    }
    final encoded = uri.queryParameters['data']!.replaceAll(' ', '+');
    final bytes = base64.decode(base64.normalize(encoded));
    if (bytes.isEmpty || bytes.length > _maxPayloadBytes) {
      throw const FormatException();
    }
    final reader = CodedBufferReader(bytes, sizeLimit: _maxPayloadBytes);
    final accounts = <OtpAccount>[];
    final seen = <int>{};
    int? version, size;
    var index = 0, id = 0;
    while (!reader.isAtEnd()) {
      final tag = reader.readTag();
      if (tag != 10 && !seen.add(tag)) throw const FormatException();
      switch (tag) {
        case 10:
          if (accounts.length >= _maxAccounts) throw const FormatException();
          accounts.add(_parseParameters(reader.readBytes()));
        case 16:
          version = reader.readInt32();
        case 24:
          size = reader.readInt32();
        case 32:
          index = reader.readInt32();
        case 40:
          id = reader.readInt32();
        default:
          throw const FormatException();
      }
    }
    if (version != 1 ||
        size == null ||
        size < 1 ||
        size > _maxBatches ||
        index < 0 ||
        index >= size ||
        (size > 1 && !seen.contains(40)) ||
        accounts.isEmpty) {
      throw const FormatException();
    }
    return MigrationBatch(id: id, size: size, index: index, accounts: accounts);
  } catch (_) {
    throw const FormatException('Invalid or unsupported migration data.');
  }
}

OtpAccount _parseParameters(Uint8List bytes) {
  final reader = CodedBufferReader(bytes, sizeLimit: _maxPayloadBytes);
  final seen = <int>{};
  Uint8List? secret;
  String name = '', issuer = '';
  int algorithm = 0, digits = 0, type = 0, counter = 0;
  while (!reader.isAtEnd()) {
    final tag = reader.readTag();
    if (!seen.add(tag)) throw const FormatException();
    switch (tag) {
      case 10:
        secret = reader.readBytes();
      case 18:
        name = utf8.decode(reader.readBytes());
      case 26:
        issuer = utf8.decode(reader.readBytes());
      case 32:
        algorithm = reader.readEnum();
      case 40:
        digits = reader.readEnum();
      case 48:
        type = reader.readEnum();
      case 56:
        final value = BigInt.parse(reader.readInt64().toString());
        if (value < BigInt.zero || value > BigInt.from(9007199254740991)) {
          throw const FormatException();
        }
        counter = value.toInt();
      default:
        throw const FormatException();
    }
  }
  if (secret == null ||
      secret.isEmpty ||
      secret.length > 128 ||
      name.trim().isEmpty) {
    throw const FormatException();
  }
  final colon = name.indexOf(':');
  if (colon >= 0) {
    final prefix = name.substring(0, colon).trim();
    if (issuer.trim().isEmpty) {
      issuer = prefix;
      name = name.substring(colon + 1).trim();
    } else if (prefix == issuer.trim()) {
      name = name.substring(colon + 1).trim();
    }
  }
  final account = OtpAccount(
    type: switch (type) {
      1 => 'hotp',
      2 => 'totp',
      _ => throw const FormatException(),
    },
    issuer: issuer.trim(),
    account: name.trim(),
    secret: base32.encode(secret).replaceAll('=', ''),
    algorithm: switch (algorithm) {
      0 || 1 => 'sha1',
      2 => 'sha256',
      3 => 'sha512',
      _ => throw const FormatException(),
    },
    digits: switch (digits) {
      0 || 1 => 6,
      2 => 8,
      _ => throw const FormatException(),
    },
    counter: counter,
  );
  account.validate();
  return account;
}

class MigrationCollector {
  final Map<int, MigrationBatch> _batches = {};
  int? _id, _size;

  int get received => _batches.length;
  int get size => _size ?? 0;
  bool get complete => _size != null && received == _size;

  void add(MigrationBatch batch) {
    if ((_id != null && _id != batch.id) ||
        (_size != null && _size != batch.size) ||
        _batches.containsKey(batch.index)) {
      throw const FormatException('Mismatched or duplicate batch.');
    }
    _id = batch.id;
    _size = batch.size;
    _batches[batch.index] = batch;
    if (_batches.values.fold<int>(
          0,
          (sum, part) => sum + part.accounts.length,
        ) >
        _maxAccounts) {
      _batches.remove(batch.index);
      throw const FormatException('Too many accounts.');
    }
  }

  List<OtpAccount> finish() {
    if (!complete) throw const FormatException('Incomplete migration.');
    final accounts = [
      for (var i = 0; i < _size!; i++) ..._batches[i]!.accounts,
    ];
    final keys = <(String, String)>{};
    for (final account in accounts) {
      account.validate();
      if (!keys.add((account.issuer, account.account))) {
        throw const FormatException('Duplicate accounts.');
      }
    }
    return accounts;
  }
}
