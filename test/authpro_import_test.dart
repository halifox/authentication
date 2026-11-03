import 'dart:convert';
import 'dart:typed_data';

import 'package:authentication/backup/authpro_import.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List encode(Map<String, Object?> value) =>
    Uint8List.fromList(utf8.encode(jsonEncode(value)));

Map<String, Object?> sample() => {
  'Authenticators': [
    {
      'Type': 2,
      'Issuer': 'Example',
      'Username': 'person',
      'Secret': 'JBSWY3DPEHPK3PXP',
      'Algorithm': 0,
      'Digits': 6,
      'Period': 30,
      'Counter': 0,
      'Ranking': 1,
      'CopyCount': 7,
    },
    {
      'Type': 1,
      'Issuer': 'Other',
      'Username': null,
      'Secret': 'GEZDGNBVGY3TQOJQ',
      'Algorithm': 1,
      'Digits': 8,
      'Period': 30,
      'Counter': 3,
      'Ranking': 0,
    },
  ],
  'Categories': [
    {'Id': 'one', 'Name': 'Work', 'Ranking': 0},
  ],
  'AuthenticatorCategories': [
    {
      'CategoryId': 'one',
      'AuthenticatorSecret': 'JBSWY3DPEHPK3PXP',
      'Ranking': 0,
    },
  ],
  'CustomIcons': [],
};

void main() {
  test('imports ordering, membership, counters and statistics', () {
    final result = parseAuthpro(encode(sample()));
    expect(result.accounts.map((a) => a.account), ['Other', 'person']);
    expect(result.accounts.first.counter, 3);
    expect(result.accounts.last.copyCount, 7);
    expect(result.categories.single.name, 'Work');
    expect(result.memberships[('Example', 'person')], ['Work']);
  });

  test('rejects invalid references and unsupported OTP parameters', () {
    final badLink = sample();
    (badLink['AuthenticatorCategories'] as List).add({
      'CategoryId': 'missing',
      'AuthenticatorSecret': 'JBSWY3DPEHPK3PXP',
      'Ranking': 0,
    });
    expect(() => parseAuthpro(encode(badLink)), throwsFormatException);
    final badDigits = sample();
    (badDigits['Authenticators'] as List).first['Digits'] = 10;
    expect(() => parseAuthpro(encode(badDigits)), throwsFormatException);
    expect(
      () => parseAuthpro(Uint8List.fromList([1, 2, 3])),
      throwsFormatException,
    );
  });
}
