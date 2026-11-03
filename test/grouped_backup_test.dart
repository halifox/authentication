import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:authentication/backup/grouped_import.dart';
import 'package:authentication/otp/otp.dart';
import 'package:authentication/storage/icon_data.dart';
import 'package:base32/base32.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'independent plain and encrypted samples contain the same accounts',
    () async {
      final plain = await File('test/fixtures/grouped_backup/plain.json')
          .readAsBytes();
      final encrypted = await File(
        'test/fixtures/grouped_backup/encrypted.json',
      ).readAsBytes();
      expect(isGroupedBackupEncrypted(plain), false);
      expect(isGroupedBackupEncrypted(encrypted), true);
      final first = await parseGroupedBackup(plain);
      final second = await parseGroupedBackup(encrypted, password: 'test');
      expect(first.accounts.length, 7);
      expect(
        second.accounts.map((a) => (a.issuer, a.account, a.type, a.counter)),
        first.accounts.map((a) => (a.issuer, a.account, a.type, a.counter)),
      );
      await expectLater(
        parseGroupedBackup(encrypted, password: 'wrong'),
        throwsFormatException,
      );
      final data = jsonDecode(utf8.decode(encrypted)) as Map<String, dynamic>;
      final header = data['header'] as Map<String, dynamic>;
      (header['params'] as Map<String, dynamic>)['tag'] =
          '00000000000000000000000000000000';
      await expectLater(
        parseGroupedBackup(
          Uint8List.fromList(utf8.encode(jsonEncode(data))),
          password: 'test',
        ),
        throwsFormatException,
      );
      ((header['slots'] as List).first as Map)['n'] = 65536;
      await expectLater(
        parseGroupedBackup(
          Uint8List.fromList(utf8.encode(jsonEncode(data))),
          password: 'test',
        ),
        throwsFormatException,
      );
    },
  );
  test(
    'rejects independent encrypted backup with unsupported account',
    () async {
      final data = await File(
        'test/fixtures/grouped_backup/icon_encrypted.json',
      ).readAsBytes();
      await expectLater(
        parseGroupedBackup(data, password: 'test'),
        throwsFormatException,
      );
    },
  );

  test(
    'imports independent icon image and rejects invalid image data',
    () async {
      final bytes = await File('test/fixtures/grouped_backup/plain.json')
          .readAsBytes();
      final data = jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
      final entries = (data['db'] as Map<String, dynamic>)['entries'] as List;
      final image = await File('test/fixtures/grouped_backup/icon.png')
          .readAsBytes();
      (entries.first as Map)['icon'] = base64Encode(image);
      Uint8List encode() => Uint8List.fromList(utf8.encode(jsonEncode(data)));
      final result = await parseGroupedBackup(encode());
      expect(validateIcon(result.accounts.first.icon), isNotEmpty);
      (entries.first as Map)['icon'] = base64Encode([1, 2, 3]);
      await expectLater(parseGroupedBackup(encode()), throwsFormatException);
    },
  );

  test('version 2 groups are converted to category memberships', () async {
    final bytes = await File('test/fixtures/grouped_backup/grouped-v2.json')
        .readAsBytes();
    final doc = await parseGroupedBackup(bytes);
    expect(
      doc.categories.map((c) => c.name),
      containsAll(['group1', 'group2']),
    );
    expect(doc.memberships[('Deno', 'Mason')], ['group1']);
    expect(doc.memberships[('Issuu', 'James')], ['group2']);
  });
  test(
    'version 3 groups and PIN-based codes match independent vectors',
    () async {
      final motpSecret = base32.encode(
        Uint8List.fromList([0xe3, 0x15, 0x2a, 0xfe, 0xe6, 0x25, 0x99, 0xc8]),
      );
      final fullYandex = base32.decode(
        '6SB2IKNM6OBZPAVBVTOHDKS4FAAAAAAADFUTQMBTRY',
      );
      final yandexSecret = base32.encode(
        Uint8List.fromList(fullYandex.take(16).toList()),
      );
      final data = {
        'version': 1,
        'header': {'slots': null, 'params': null},
        'db': {
          'version': 3,
          'groups': [
            {'uuid': '01234567-89ab-cdef-0123-456789abcdef', 'name': 'Work'},
          ],
          'entries': [
            {
              'type': 'motp',
              'issuer': 'Example',
              'name': 'mobile',
              'info': {
                'secret': motpSecret,
                'algo': 'MD5',
                'digits': 6,
                'period': 10,
                'pin': '1234',
              },
              'groups': ['01234567-89ab-cdef-0123-456789abcdef'],
            },
            {
              'type': 'yandex',
              'issuer': 'Example',
              'name': 'yandex',
              'info': {
                'secret': yandexSecret,
                'algo': 'SHA256',
                'digits': 8,
                'period': 30,
                'pin': '5239',
              },
              'groups': [],
            },
          ],
        },
      };
      final doc = await parseGroupedBackup(
        Uint8List.fromList(utf8.encode(jsonEncode(data))),
      );
      final mobile = doc.accounts.first;
      final yandex = doc.accounts.last;
      expect(doc.memberships[('Example', 'mobile')], ['Work']);
      expect(
        OTP
            .generateMOTPCodeString(
              secret: mobile.secret,
              pin: mobile.pin,
              intervalSeconds: mobile.period,
              unixMilliseconds: 165892298000,
            )
            .toLowerCase(),
        'e7d8b6',
      );
      expect(
        OTP.generateYandexCode(
          secret: yandex.secret,
          pin: yandex.pin,
          unixMilliseconds: 1641559648000,
        ),
        'umozdicq',
      );
      ((data['db'] as Map)['entries'] as List).first['groups'] = ['missing'];
      await expectLater(
        parseGroupedBackup(Uint8List.fromList(utf8.encode(jsonEncode(data)))),
        throwsFormatException,
      );
    },
  );
}
