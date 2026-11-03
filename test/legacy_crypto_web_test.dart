import 'dart:convert';

import 'package:authentication/backup/legacy_import.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'current encrypted fixture decrypts with the platform key derivation',
    () async {
      final bytes = base64Decode(
        'AAALGDNKnj5TCdtHnuOTl2ikWY819lz0VEQwWNiLj+ODkXzsRIXXyI7beU8lEo82TbYFIb1nfhLCjptIxX0LNQVpLNzbrYIYwwPdekwk9/eAQ/mZxA5qRzrt3jZSQX8sZzAlex0XZVDRVBOjf/mjriieIDbgmMaPNnEbw03zpAKbtwrb3fi0vG8MNYgmMah/I/YN/zRbJc6WB7O6+l6hD1m7I2LIQ5biTZngzBCu5jd0Dzd8qvALNWigGZ114gUj8+QltbVcq3lsnB1X',
      );
      final plaintext = await decryptLegacyBackup(
        bytes,
        LegacyBackupFormat.encrypted,
        password: '123456',
      );
      expect(
        (jsonDecode(utf8.decode(plaintext)) as List).single['label'],
        'test',
      );
    },
  );
}
