import 'dart:io';

import 'package:auth/auth.dart';
import 'package:auth/encrypt_codec.dart';
import 'package:auth/otp.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

typedef Listener = void Function(List<AuthConfig>);

late final Database db;
final StoreRef<String, Map<String, Object?>> authStore = stringMapStoreFactory.store('auth');
final StoreRef<String, Map<String, Object?>> settingsStore = stringMapStoreFactory.store('settings');

Future<void> initDatabase() async {
  SembastCodec? codec;
  String path;
  if (kReleaseMode) {
    path = 'auth.db';
    codec = getEncryptSembastCodec(password: '99999');
  } else {
    path = 'auth.debug.db';
    codec = null;
  }
  if (kIsWeb) {
    db = await databaseFactoryWeb.openDatabase(path, codec: codec);
  } else {
    final Directory dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    db = await databaseFactoryIo.openDatabase(join(dir.path, path), codec: codec);
  }
  if (kDebugMode) {
    await settingsStore.delete(db);
    await authStore.delete(db);
    await authStore.add(db, AuthConfig(secret: OTP.randomSecret(), type: 'totp', account: "user@github.com", issuer: "GitHub", period: 30).toJson());
    await authStore.add(db, AuthConfig(secret: OTP.randomSecret(), type: 'totp', account: "user@gmail.com", issuer: "Google", period: 30).toJson());
    await authStore.add(db, AuthConfig(secret: OTP.randomSecret(), type: 'totp', account: "user@icloud.com", issuer: "Apple", period: 40).toJson());
    await authStore.add(db, AuthConfig(secret: OTP.randomSecret(), type: 'totp', account: "user@dropbox.com", issuer: "Dropbox", period: 45).toJson());
    await authStore.add(db, AuthConfig(secret: OTP.randomSecret(), type: 'totp', account: "user@1dot1dot1dot1.com", issuer: "1dot1dot1dot1", period: 60).toJson());
    await authStore.add(db, AuthConfig(secret: OTP.randomSecret(), type: 'hotp', account: "user@aws.com", issuer: "Amazon", counter: 0).toJson());
    await authStore.add(db, AuthConfig(secret: OTP.randomSecret(), type: 'hotp', account: "user@ansible.com", issuer: "ansible", counter: 0).toJson());
  }
  await settingsStore.record('settings').put(db, {'biometricUnlock': false, 'isShowCaptchaOnTap': false, 'isCopyCaptchaOnTap': false}, ifNotExists: true);
}
