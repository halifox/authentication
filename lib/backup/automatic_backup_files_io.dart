import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show listEquals;

Future<String?> pickLocalBackupDirectory() => FilePicker.getDirectoryPath();

Future<bool> isLocalBackupDirectory(String path) async {
  final directory = Directory(path);
  if (!directory.isAbsolute ||
      (Platform.isWindows &&
          (path.startsWith(r'\\') || path.startsWith('//')))) {
    return false;
  }
  return directory.exists();
}

/// Create a new file exclusively. A failed write never replaces an old backup.
Future<void> writeLocalBackup(
  String directory,
  String name,
  Uint8List bytes,
) async {
  if (!await isLocalBackupDirectory(directory) ||
      !RegExp(r'^authentication-[0-9a-f]{32}\.json$').hasMatch(name)) {
    throw const FormatException('Invalid backup destination.');
  }
  final file = File(
    '${Directory(directory).path}${Platform.pathSeparator}$name',
  );
  var created = false;
  try {
    await file.create(exclusive: true);
    created = true;
    final output = await file.open(mode: FileMode.writeOnly);
    try {
      await output.writeFrom(bytes);
      await output.flush();
    } finally {
      await output.close();
    }
    final input = await file.open();
    try {
      if (!listEquals(await input.read(bytes.length + 1), bytes)) {
        throw const FormatException('Backup verification failed.');
      }
    } finally {
      await input.close();
    }
  } catch (_) {
    if (created) {
      try {
        await file.delete();
      } catch (_) {}
    }
    rethrow;
  }
}
