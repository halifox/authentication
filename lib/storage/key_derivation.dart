import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute;
import 'package:pointycastle/export.dart' as pc;

Uint8List _derive(List<Object> args) {
  final digest = args[3] == true ? pc.SHA1Digest() : pc.SHA256Digest();
  final derivator = pc.PBKDF2KeyDerivator(pc.HMac(digest, 64))
    ..init(pc.Pbkdf2Parameters(args[1] as Uint8List, args[2] as int, 32));
  return derivator.process(Uint8List.fromList(utf8.encode(args[0] as String)));
}

Future<Uint8List> derivePbkdf2Key(
  String password,
  Uint8List salt,
  int iterations, {
  bool sha1 = false,
}) => compute(_derive, [password, salt, iterations, sha1]);
