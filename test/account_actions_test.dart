import 'package:authentication/actions/account_actions.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('form adds, detects conflicts and updates encrypted accounts', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final db = AppDatabase(NativeDatabase.memory());
    addTearDown(db.close);
    db.encryption = await EncryptionService.initialize(db);
    Future<TokenFormResult> save({int? id}) => saveAccount(
      db,
      id: id,
      type: 'totp',
      issuer: 'Example',
      account: 'user',
      secret: 'JBSWY3DPEHPK3PXP',
      algorithm: 'sha1',
      digits: 6,
      period: 30,
      counter: 0,
      pin: '',
      icon: 'assets/icons/passkey.svg',
    );
    expect(await save(), isA<TokenFormSuccess>());
    expect(await save(), isA<TokenFormConflict>());
    final entries = await db.getAllConfigs();
    expect(await save(id: entries.single.id), isA<TokenFormSuccess>());
    expect(
      (await db.getAllAuthEntries()).single.secret,
      isNot('JBSWY3DPEHPK3PXP'),
    );
  });
}
