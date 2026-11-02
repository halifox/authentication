import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart' as pc;

Uint8List _derive(List<Object> args) {
  final derivator = pc.PBKDF2KeyDerivator(pc.HMac(pc.SHA256Digest(), 64))
    ..init(pc.Pbkdf2Parameters(args[1] as Uint8List, args[2] as int, 32));
  return derivator.process(Uint8List.fromList(utf8.encode(args[0] as String)));
}

Future<Uint8List> deriveBackupKey(
  String password,
  Uint8List salt,
  int iterations,
) => compute(_derive, [password, salt, iterations]);
