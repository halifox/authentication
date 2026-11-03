import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:authentication/backup/freeotp_import.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pointycastle/export.dart' as pc;

Uint8List sha1Variant(Uint8List bytes) {
  final header = bytes.sublist(0, 81);
  var offset = 81;
  final pairs = <(String, String)>[];
  while (offset < bytes.length - 1) {
    String readString() {
      if (bytes[offset++] != 0x74) throw const FormatException();
      final length = (bytes[offset++] << 8) | bytes[offset++];
      final text = utf8.decode(bytes.sublist(offset, offset + length));
      offset += length;
      return text;
    }

    pairs.add((readString(), readString()));
  }
  final masterIndex = pairs.indexWhere((pair) => pair.$1 == 'masterKey');
  final master = jsonDecode(pairs[masterIndex].$2) as Map<String, dynamic>;
  final salt = Uint8List.fromList(
    (master['mSalt'] as List).cast<int>().map((v) => v & 255).toList(),
  );
  Uint8List derive(pc.Digest digest, int blockSize) {
    final kdf = pc.PBKDF2KeyDerivator(pc.HMac(digest, blockSize))
      ..init(pc.Pbkdf2Parameters(salt, master['mIterations'] as int, 32));
    return kdf.process(Uint8List.fromList(utf8.encode('test')));
  }

  final encrypted = master['mEncryptedKey'] as Map<String, dynamic>;
  Uint8List signed(String key) => Uint8List.fromList(
    (encrypted[key] as List).cast<int>().map((v) => v & 255).toList(),
  );
  final params = signed('mParameters');
  final aad = Uint8List.fromList(utf8.encode(encrypted['mToken'] as String));
  final nonce = params.sublist(4, 16);
  Uint8List crypt(bool encrypt, Uint8List key, Uint8List input) {
    final cipher = pc.GCMBlockCipher(pc.AESEngine())
      ..init(encrypt, pc.AEADParameters(pc.KeyParameter(key), 128, nonce, aad));
    return cipher.process(input);
  }

  final masterKey = crypt(
    false,
    derive(pc.SHA512Digest(), 128),
    signed('mCipherText'),
  );
  final ciphertext = crypt(true, derive(pc.SHA1Digest(), 64), masterKey);
  encrypted['mCipherText'] = ciphertext
      .map((v) => v < 128 ? v : v - 256)
      .toList();
  master['mAlgorithm'] = 'PBKDF2withHmacSHA1';
  pairs[masterIndex] = (pairs[masterIndex].$1, jsonEncode(master));
  final builder = BytesBuilder()..add(header);
  for (final pair in pairs) {
    for (final value in [pair.$1, pair.$2]) {
      final data = utf8.encode(value);
      builder.add([0x74, data.length >> 8, data.length & 255, ...data]);
    }
  }
  builder.addByte(0x78);
  return builder.takeBytes();
}

void main() {
  test(
    'decrypts independent sample and rejects unsupported complete file',
    () async {
      final supported = await File('test/fixtures/freeotp/supported.bin')
          .readAsBytes();
      final source = await File('test/fixtures/freeotp/source.bin')
          .readAsBytes();
      final result = await parseFreeOtpBackup(supported, 'test');
      expect(result.accounts.length, 6);
      expect(
        (await parseFreeOtpBackup(
          sha1Variant(supported),
          'test',
        )).accounts.length,
        6,
      );
      expect(result.accounts.any((a) => a.type == 'hotp'), isTrue);
      await expectLater(
        parseFreeOtpBackup(source, 'test'),
        throwsFormatException,
      );
      await expectLater(
        parseFreeOtpBackup(supported, 'wrong'),
        throwsFormatException,
      );
      await expectLater(
        parseFreeOtpBackup(
          Uint8List.fromList(supported.sublist(0, 100)),
          'test',
        ),
        throwsFormatException,
      );
    },
  );
}
