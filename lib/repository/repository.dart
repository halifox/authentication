import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';

import 'auth.dart';
import 'encrypt_codec.dart';
import 'otp.dart';

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
    await authStore.add(
      db,
      AuthConfig(
        secret: OTP.randomSecret(),
        type: 'totp',
        account: 'user@github.com',
        issuer: 'GitHub',
        period: 30,
        icon: 'assets/icons/github.svg',
      ).toJson(),
    );
    await authStore.add(
      db,
      AuthConfig(
        secret: OTP.randomSecret(),
        type: 'totp',
        account: 'user@gmail.com',
        issuer: 'Google',
        period: 30,
        icon: 'assets/icons/gmail.svg',
      ).toJson(),
    );
    await authStore.add(
      db,
      AuthConfig(
        secret: OTP.randomSecret(),
        type: 'totp',
        account: 'user@icloud.com',
        issuer: 'Apple',
        period: 40,
        icon: 'assets/icons/apple.svg',
      ).toJson(),
    );
    await authStore.add(
      db,
      AuthConfig(
        secret: OTP.randomSecret(),
        type: 'totp',
        account: 'user@dropbox.com',
        issuer: 'Dropbox',
        period: 45,
        icon: 'assets/icons/dropbox.svg',
      ).toJson(),
    );
    await authStore.add(
      db,
      AuthConfig(
        secret: OTP.randomSecret(),
        type: 'totp',
        account: 'user@1dot1dot1dot1.com',
        issuer: '1dot1dot1dot1',
        period: 60,
        icon: 'assets/icons/1dot1dot1dot1.svg',
      ).toJson(),
    );
    await authStore.add(
      db,
      AuthConfig(
        secret: OTP.randomSecret(),
        type: 'hotp',
        account: 'user@aws.com',
        issuer: 'Amazon',
        counter: 0,
        icon: 'assets/icons/amazon.svg',
      ).toJson(),
    );
    await authStore.add(
      db,
      AuthConfig(
        secret: OTP.randomSecret(),
        type: 'hotp',
        account: 'user@ansible.com',
        issuer: 'ansible',
        counter: 0,
        icon: 'assets/icons/ansible.svg',
      ).toJson(),
    );
  }
  await settingsStore.record('settings').put(db, {
    'biometricUnlock': false,
    'isShowCaptchaOnTap': false,
    'isCopyCaptchaOnTap': false,
  }, ifNotExists: true);
}
