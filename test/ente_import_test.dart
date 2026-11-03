import 'dart:io';

import 'package:authentication/backup/backup.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('imports independent plaintext export', () {
    final bytes = File('test/fixtures/ente/plain.txt').readAsBytesSync();
    final accounts = decodeUriList(bytes);
    expect(accounts.length, 7);
    expect(accounts.where((account) => account.type == 'hotp').length, 1);
    expect(accounts.any((account) => account.period == 60), isTrue);
  });
}
