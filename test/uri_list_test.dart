import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/otp/account.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const accounts = [
    OtpAccount(
      type: 'totp',
      issuer: 'Example',
      account: 'alice',
      secret: 'JBSWY3DPEHPK3PXP',
    ),
    OtpAccount(
      type: 'hotp',
      issuer: 'Example',
      account: 'bob',
      secret: 'JBSWY3DPEHPK3PXP',
      counter: 42,
    ),
  ];

  test('URI list round trips accounts and HOTP counter', () {
    final decoded = decodeUriList(encodeUriList(accounts));
    expect(decoded.map((e) => e.account), ['alice', 'bob']);
    expect(decoded.last.counter, 42);
  });

  test('rejects empty, oversized, malformed and partially invalid lists', () {
    expect(() => decodeUriList(Uint8List(0)), throwsFormatException);
    expect(
      () => decodeUriList(Uint8List(maxBackupBytes + 1)),
      throwsFormatException,
    );
    final valid = accounts.first.toOtpUri();
    final ambiguous = '$valid&secret=AAAAAAAAAAAAAAAA';
    expect(
      () => decodeUriList(
        Uint8List.fromList(
          utf8.encode('${accounts.last.toOtpUri()}\n$ambiguous'),
        ),
      ),
      throwsFormatException,
    );
    expect(
      () => decodeUriList(Uint8List.fromList(utf8.encode('$valid\n$valid'))),
      throwsFormatException,
    );
    expect(
      () => decodeUriList(Uint8List.fromList(utf8.encode('$valid\ninvalid'))),
      throwsA(anything),
    );
    expect(
      () => decodeUriList(Uint8List.fromList([0xff])),
      throwsFormatException,
    );
  });
}
