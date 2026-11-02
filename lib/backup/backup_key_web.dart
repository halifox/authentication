import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

@JS()
@anonymous
extension type _Pbkdf2Params._(JSObject _) implements JSObject {
  external factory _Pbkdf2Params({
    required String name,
    required JSUint8Array salt,
    required int iterations,
    required String hash,
  });
}

Future<Uint8List> deriveBackupKey(
  String password,
  Uint8List salt,
  int iterations,
) async {
  final subtle = web.window.crypto.subtle;
  final material = await subtle
      .importKey(
        'raw',
        Uint8List.fromList(utf8.encode(password)).toJS,
        'PBKDF2'.toJS,
        false,
        ['deriveBits'.toJS].toJS,
      )
      .toDart;
  final result = await subtle
      .deriveBits(
        _Pbkdf2Params(
          name: 'PBKDF2',
          salt: salt.toJS,
          iterations: iterations,
          hash: 'SHA-256',
        ),
        material,
        256,
      )
      .toDart;
  return result.toDart.asUint8List();
}
