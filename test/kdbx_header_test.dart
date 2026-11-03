import 'dart:io';
import 'dart:typed_data';

import 'package:authentication/backup/kdbx_decrypt.dart';
import 'package:authentication/backup/kdbx_header.dart';
import 'package:authentication/backup/kdbx_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reads independent KDF and data-block variants', () async {
    for (final name in ['argon2id', 'argon2d', 'uncompressed']) {
      final bytes = File('test/fixtures/kdbx/$name.kdbx').readAsBytesSync();
      final result = parseKdbxPayload(await decryptKdbx(bytes, 'test'));
      expect(result.accounts.length, 7, reason: name);
    }
    final excessive = File('test/fixtures/kdbx/multiblock.kdbx')
        .readAsBytesSync();
    await expectLater(decryptKdbx(excessive, 'test'), throwsFormatException);
  });
  test('reads groups and excludes recycle bin entries', () async {
    final groups = File('test/fixtures/kdbx/groups.kdbx').readAsBytesSync();
    final result = parseKdbxPayload(await decryptKdbx(groups, 'test'));
    expect(result.accounts.length, 7);
    expect(result.categories, isNotEmpty);
    final recycle = File('test/fixtures/kdbx/recycle.kdbx').readAsBytesSync();
    expect(
      () async => parseKdbxPayload(await decryptKdbx(recycle, 'test')),
      throwsFormatException,
    );
  });
  test('authenticates and decrypts independent database', () async {
    final bytes = File('test/fixtures/kdbx/aes.kdbx').readAsBytesSync();
    final plain = await decryptKdbx(bytes, 'test');
    expect(plain.length, greaterThan(100));
    expect(parseKdbxPayload(plain).accounts.length, 7);
    expect(
      () => parseKdbxPayload(
        Uint8List.fromList([...plain, ...List.filled(100001, 60)]),
      ),
      throwsFormatException,
    );
    await expectLater(decryptKdbx(bytes, 'wrong'), throwsFormatException);
    final damaged = Uint8List.fromList(bytes)..[bytes.length - 45] ^= 1;
    await expectLater(decryptKdbx(damaged, 'test'), throwsFormatException);
  });
  test('inspects independent version 4 KDF headers before derivation', () {
    for (final name in ['argon2id', 'aes']) {
      final bytes = File('test/fixtures/kdbx/$name.kdbx').readAsBytesSync();
      final header = readKdbxHeader(bytes);
      expect(header.kdf[r'$UUID'], hasLength(16));
      expect(header.kdf['S'], hasLength(32));
      expect(header.bytes.length, lessThan(bytes.length));
      final unknown = Uint8List.fromList(bytes)..[12] = 99;
      expect(() => readKdbxHeader(unknown), throwsFormatException);
      expect(
        () => readKdbxHeader(
          Uint8List.sublistView(bytes, 0, header.bytes.length - 1),
        ),
        throwsFormatException,
      );
    }
    final v3 = File('test/fixtures/kdbx/v3.kdbx').readAsBytesSync();
    expect(() => readKdbxHeader(v3), throwsFormatException);
  });
  test('rejects excessive KDF work before deriving a key', () {
    final bytes = File('test/fixtures/kdbx/argon2id.kdbx').readAsBytesSync();
    final header = readKdbxHeader(bytes);
    final memory = header.kdf['M'] as int;
    final parameters = header.fields[11]!;
    final marker = Uint8List.fromList([1, 0, 0, 0, 77, 8, 0, 0, 0]);
    final offset = List.generate(parameters.length - marker.length, (i) => i)
        .firstWhere(
          (i) => List.generate(
            marker.length,
            (j) => parameters[i + j] == marker[j],
          ).every((value) => value),
        );
    expect(
      ByteData.sublistView(parameters)
          .getUint32(offset + marker.length, Endian.little),
      memory,
    );
    ByteData.sublistView(parameters)
        .setUint32(offset + marker.length, 536870912, Endian.little);
    expect(() => readKdbxHeader(bytes), throwsFormatException);
  });
}
