import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:authentication/backup/twofas_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('imports independent plaintext and encrypted samples', () async {
    final plain = await File('test/fixtures/twofas/unencrypted.json')
        .readAsBytes();
    final encrypted = await File('test/fixtures/twofas/encrypted.json')
        .readAsBytes();
    expect(isTwoFasEncrypted(plain), isFalse);
    expect(isTwoFasEncrypted(encrypted), isTrue);
    final a = await parseTwoFasBackup(plain);
    final b = await parseTwoFasBackup(encrypted, password: 'test');
    expect(a.accounts.length, 6);
    expect(b.accounts.length, 6);
    expect(a.categories.single.name, b.categories.single.name);
    expect(a.memberships.values.where((groups) => groups.isNotEmpty).length, 2);
    expect(b.memberships.values.where((groups) => groups.isNotEmpty).length, 2);
    expect(a.accounts.where((x) => x.type == 'hotp').single.counter, 10);
    await expectLater(
      parseTwoFasBackup(encrypted, password: 'wrong'),
      throwsFormatException,
    );
    final damaged = jsonDecode(utf8.decode(encrypted)) as Map<String, dynamic>;
    final parts = (damaged['servicesEncrypted'] as String).split(':');
    final ciphertext = base64Decode(parts[0]);
    ciphertext[0] ^= 1;
    parts[0] = base64Encode(ciphertext);
    damaged['servicesEncrypted'] = parts.join(':');
    await expectLater(
      parseTwoFasBackup(
        Uint8List.fromList(utf8.encode(jsonEncode(damaged))),
        password: 'test',
      ),
      throwsFormatException,
    );
  });

  test('rejects invalid references before import', () async {
    final input = await File('test/fixtures/twofas/unencrypted.json')
        .readAsBytes();
    final data = jsonDecode(utf8.decode(input)) as Map<String, dynamic>;
    (data['services'] as List).first['groupId'] = 'missing';
    await expectLater(
      parseTwoFasBackup(Uint8List.fromList(utf8.encode(jsonEncode(data)))),
      throwsFormatException,
    );
  });
}
