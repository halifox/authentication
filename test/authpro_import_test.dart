import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:authentication/backup/authpro_import.dart';
import 'package:authentication/storage/icon_data.dart';
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
  test('decrypts independent encrypted format samples', () async {
    const strong = [
      65,
      85,
      84,
      72,
      69,
      78,
      84,
      73,
      67,
      65,
      84,
      79,
      82,
      80,
      82,
      79,
    ];
    const legacy = [
      65,
      117,
      116,
      104,
      101,
      110,
      116,
      105,
      99,
      97,
      116,
      111,
      114,
      80,
      114,
      111,
    ];
    for (final variant in [('strong', strong), ('legacy', legacy)]) {
      final body = await File('test/fixtures/authpro_${variant.$1}.bin')
          .readAsBytes();
      final bytes = Uint8List.fromList([...variant.$2, ...body]);
      final decoded = jsonDecode(
        utf8.decode(await decryptAuthpro(bytes, password: 'test')),
      );
      expect((decoded as Map)['Authenticators'], isA<List>());
      await expectLater(
        decryptAuthpro(bytes, password: 'wrong'),
        throwsFormatException,
      );
      await expectLater(
        decryptAuthpro(bytes.sublist(0, 20), password: 'test'),
        throwsFormatException,
      );
      if (variant.$1 == 'strong') {
        bytes[bytes.length - 1] ^= 1;
        await expectLater(
          decryptAuthpro(bytes, password: 'test'),
          throwsFormatException,
        );
      }
    }
  });

  test(
    'imports source image and rejects missing or invalid icon references',
    () {
      final data = sample();
      final png = File('test/fixtures/authpro_icon.png').readAsBytesSync();
      data['CustomIcons'] = [
        {'Id': 'sample', 'Data': base64Encode(png)},
      ];
      (data['Authenticators'] as List).first['Icon'] = '@sample';
      final parsed = parseAuthpro(encode(data));
      expect(validateIcon(parsed.accounts.last.icon), isNotEmpty);
      (data['Authenticators'] as List).first['Icon'] = '@missing';
      expect(() => parseAuthpro(encode(data)), throwsFormatException);
      (data['Authenticators'] as List).first['Icon'] = '@sample';
      (data['CustomIcons'] as List).first['Data'] = base64Encode([1, 2, 3]);
      expect(() => parseAuthpro(encode(data)), throwsFormatException);
    },
  );

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
