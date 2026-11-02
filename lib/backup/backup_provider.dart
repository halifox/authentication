import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:authentication/storage/database_provider.dart';
import 'package:authentication/storage/database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BackupOperations extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<T> _run<T>(Future<T> Function() action) async {
    if (state.isLoading)
      throw StateError('A backup operation is already running.');
    state = const AsyncLoading();
    try {
      final result = await action();
      state = const AsyncData(null);
      return result;
    } catch (error, stack) {
      state = AsyncError(error, stack);
      rethrow;
    }
  }

  Future<Uint8List?> pickFile() => _run(() async {
    final file = await FilePicker.pickFile();
    if (file == null) return null;
    final size = await file.length();
    if (size != null && size > maxBackupBytes)
      throw const FormatException('File too large');
    final buffer = BytesBuilder(copy: false);
    await for (final chunk in file.readAsByteStream()) {
      if (buffer.length + chunk.length > maxBackupBytes)
        throw const FormatException('File too large');
      buffer.add(chunk);
    }
    return buffer.takeBytes();
  });

  Future<bool> exportFile(String? password) {
    final db = ref.read(appDatabaseProvider);
    return _run(() async {
      final accounts = await db.getAllConfigs();
      if (accounts.isEmpty) throw StateError('No accounts to export.');
      final bytes = await encodeBackupAccounts(accounts, password);
      final location = await FilePicker.saveFile(
        fileName: 'authentication-backup.json',
        bytes: bytes,
        mimeType: 'application/json',
      );
      return location != null || kIsWeb;
    });
  }

  Future<int> import(Uint8List bytes, String? password) {
    final db = ref.read(appDatabaseProvider);
    return _run(
      () async =>
          db.importAccounts(await decodeBackupAccounts(bytes, password)),
    );
  }
}

final backupOperationsProvider =
    NotifierProvider<BackupOperations, AsyncValue<void>>(BackupOperations.new);
