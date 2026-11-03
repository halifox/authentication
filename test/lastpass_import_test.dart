import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:authentication/backup/lastpass_import.dart';
import 'package:flutter_test/flutter_test.dart';

Uint8List bytes(Object value) =>
    Uint8List.fromList(utf8.encode(jsonEncode(value)));

void main() {
  test('rejects unsupported records and imports supported independent sample records', () {
    final data = jsonDecode(
      File('test/fixtures/lastpass/sample.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    expect(() => parseLastPassBackup(bytes(data)), throwsFormatException);
    (data['accounts'] as List).removeWhere((entry) => entry['digits'] == 9);
    final parsed = parseLastPassBackup(bytes(data));
    expect(parsed.accounts.length, 5);
    expect(parsed.categories.length, 2);
    expect(parsed.memberships.values.where((v) => v.isNotEmpty).length, 3);
    expect(parsed.accounts.any((a) => a.period == 60), isTrue);
    ((data['accounts'] as List).first['folderData'] as Map)['folderId'] = 999;
    expect(() => parseLastPassBackup(bytes(data)), throwsFormatException);
  });
}
