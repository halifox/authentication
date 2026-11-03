import 'dart:typed_data';

Future<String?> pickLocalBackupDirectory() async =>
    throw UnsupportedError('Unsupported platform');
Future<bool> isLocalBackupDirectory(String path) async => false;
Future<void> writeLocalBackup(
  String directory,
  String name,
  Uint8List bytes,
) async => throw UnsupportedError('Unsupported platform');
