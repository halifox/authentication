import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:authentication/backup/winauth_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('independent accounts ZIP requires password and validates the file', () {
    final bytes = File('test/fixtures/plus.zip').readAsBytesSync();
    expect(
      () => parseWinAuthBackup(bytes, password: 'wrong', accountsZip: true),
      throwsFormatException,
    );
    final result = parseWinAuthBackup(
      bytes,
      password: 'testtesttest',
      accountsZip: true,
    );
    expect(result.accounts, isNotEmpty);
    final plain = Archive()
      ..addFile(
        ArchiveFile.string(
          'Accounts.txt',
          'otpauth://totp/Example:user?secret=JBSWY3DPEHPK3PXP&issuer=Example',
        ),
      );
    final plainZip = Uint8List.fromList(ZipEncoder().encode(plain));
    expect(
      () => parseWinAuthBackup(
        plainZip,
        password: 'any-password',
        accountsZip: true,
      ),
      throwsFormatException,
    );
    final forged = Uint8List.fromList(plainZip);
    final central = List.generate(forged.length - 3, (i) => i).firstWhere(
      (i) =>
          forged[i] == 0x50 &&
          forged[i + 1] == 0x4b &&
          forged[i + 2] == 1 &&
          forged[i + 3] == 2,
    );
    forged[central + 8] |= 1;
    expect(
      () => parseWinAuthBackup(
        forged,
        password: 'any-password',
        accountsZip: true,
      ),
      throwsFormatException,
    );
    expect(
      () => parseWinAuthBackup(
        File('test/fixtures/winauth.zip').readAsBytesSync(),
        password: 'test',
        accountsZip: true,
      ),
      throwsFormatException,
    );
    final damaged = Uint8List.fromList(bytes)..[80] ^= 1;
    expect(
      () => parseWinAuthBackup(
        damaged,
        password: 'testtesttest',
        accountsZip: true,
      ),
      throwsFormatException,
    );
  });
  test('independent encrypted ZIP sample requires correct password', () {
    final bytes = File('test/fixtures/winauth.zip').readAsBytesSync();
    expect(isWinAuthZip(bytes), isTrue);
    expect(
      () => parseWinAuthBackup(bytes, password: 'wrong'),
      throwsFormatException,
    );
    final result = parseWinAuthBackup(bytes, password: 'test');
    expect(result.accounts.length, 1);
    expect(result.accounts.single.type, 'totp');
    final oversized = Uint8List.fromList(bytes);
    final offset = List.generate(oversized.length - 3, (i) => i).firstWhere(
      (i) =>
          oversized[i] == 0x50 &&
          oversized[i + 1] == 0x4b &&
          oversized[i + 2] == 0x01 &&
          oversized[i + 3] == 0x02,
    );
    ByteData.sublistView(oversized)
        .setUint32(offset + 24, 20 * 1024 * 1024, Endian.little);
    expect(
      () => parseWinAuthBackup(oversized, password: 'test'),
      throwsFormatException,
    );
    final damaged = Uint8List.fromList(bytes);
    damaged[60] ^= 0x80;
    expect(
      () => parseWinAuthBackup(damaged, password: 'test'),
      throwsFormatException,
    );
  });
}
