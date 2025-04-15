import 'dart:io';

import 'package:auth/otp.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:auth/auth.dart';
import 'package:auth/encrypt_codec.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

typedef Listener = void Function(List<AuthConfig>);

final StoreRef<String, Map<String, Object?>> authStore = stringMapStoreFactory.store();
final StoreRef<String, Object?> settingsStore = StoreRef<String, Object?>('settings');
late final Database db;

initDatabase() async {
  if (kIsWeb) {
    db = await EncryptedDatabaseFactory(databaseFactory: databaseFactoryWeb, password: '99999').openDatabase('auth');
  } else {
    final Directory dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    final String path = join(dir.path, 'auth');
    // db = await EncryptedDatabaseFactory(databaseFactory: databaseFactoryIo, password: '99999').openDatabase(path);
    db = await databaseFactoryIo.openDatabase(path);
  }

  await settingsStore.record('biometricUnlock').put(db, false, ifNotExists: true);
  await settingsStore.record('isShowCaptchaOnTap').put(db, false, ifNotExists: true);
  await settingsStore.record('isCopyCaptchaOnTap').put(db, false, ifNotExists: true);

  if (kDebugMode) {
    await authStore.delete(db);
    await authStore.add(db, AuthConfig(secret: OTP.randomSecret(), type: Type.totp, account: "user@github.com", issuer: "GitHub", intervalSeconds: 30).toJson());
    await authStore.add(db, AuthConfig(secret: OTP.randomSecret(), type: Type.totp, account: "user@gmail.com", issuer: "Google", intervalSeconds: 30).toJson());
    await authStore.add(db, AuthConfig(secret: OTP.randomSecret(), type: Type.totp, account: "user@icloud.com", issuer: "Apple", intervalSeconds: 40).toJson());
    await authStore.add(db, AuthConfig(secret: OTP.randomSecret(), type: Type.totp, account: "user@dropbox.com", issuer: "Dropbox", intervalSeconds: 45).toJson());
    await authStore.add(db, AuthConfig(secret: OTP.randomSecret(), type: Type.totp, account: "user@1dot1dot1dot1.com", issuer: "1dot1dot1dot1", intervalSeconds: 60).toJson());
    await authStore.add(db, AuthConfig(secret: OTP.randomSecret(), type: Type.hotp, account: "user@aws.com", issuer: "Amazon", counter: 0).toJson());
    await authStore.add(db, AuthConfig(secret: OTP.randomSecret(), type: Type.hotp, account: "user@ansible.com", issuer: "ansible", counter: 0).toJson());
  }
}
