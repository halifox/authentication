import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:auth/auth.dart';
import 'package:auth/encrypt_codec.dart';
import 'package:auth/otp.dart';
import 'package:sembast/sembast_io.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef Listener = void Function(List<AuthenticationConfig>);

late final StoreRef<String, Map<String, Object?>> authStore;
late final Database db;

initDatabase() async {
  authStore = stringMapStoreFactory.store();
  if (kIsWeb) {
    db = await EncryptedDatabaseFactory(databaseFactory: databaseFactoryWeb, password: '99999').openDatabase('auth');
  } else {
    final Directory dir = await getApplicationDocumentsDirectory();
    await dir.create(recursive: true);
    final String path = join(dir.path, 'auth');
    // db = await EncryptedDatabaseFactory(databaseFactory: databaseFactoryIo, password: '99999').openDatabase(path);
    db = await databaseFactoryIo.openDatabase(path);
  }
}

late final SharedPreferences sp;

initSharedPreferences() async {
  sp = await SharedPreferences.getInstance();
}
