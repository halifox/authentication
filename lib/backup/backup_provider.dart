import 'dart:typed_data';

import 'package:authentication/backup/backup.dart';
import 'package:authentication/backup/html_backup.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:hooks_riverpod/hooks_riverpod.dart';

class BackupOperations extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<T> _run<T>(Future<T> Function() action) async {
    if (state.isLoading) {
      throw StateError('A backup operation is already running.');
    }
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
    if (size != null && size > maxBackupBytes) {
      throw const FormatException('File too large');
    }
    final buffer = BytesBuilder(copy: false);
    await for (final chunk in file.readAsByteStream()) {
      if (buffer.length + chunk.length > maxBackupBytes) {
        throw const FormatException('File too large');
      }
      buffer.add(chunk);
    }
    return buffer.takeBytes();
  });

  Future<bool> exportFile(String? password) {
    final db = ref.read(appDatabaseProvider);
    return _run(() async {
      final snapshot = await db.transaction(
        () async => (
          accounts: await db.getAllConfigs(),
          settings: await db.getSettings(),
          integerSettings: await db.getIntegerSettings(),
          categories: await db.getCategories(),
          membershipIds: await db.getCategoryMemberships(),
        ),
      );
      final names = {
        for (final category in snapshot.categories) category.id: category.name,
      };
      final accountIds = snapshot.accounts.map((account) => account.id).toSet();
      final memberships = <int, List<String>>{};
      for (final entry in snapshot.membershipIds.entries) {
        if (!accountIds.contains(entry.key) ||
            entry.value.any((id) => !names.containsKey(id))) {
          throw StateError('Invalid category membership.');
        }
        memberships[entry.key] = [
          for (final category in snapshot.categories)
            if (entry.value.contains(category.id)) category.name,
        ];
      }
      final bytes = await encodeBackupAccounts(
        snapshot.accounts,
        password,
        settings: snapshot.settings,
        integerSettings: snapshot.integerSettings,
        includeCopyCounts: true,
        categories: snapshot.categories,
        memberships: memberships,
      );
      final location = await FilePicker.saveFile(
        fileName: 'authentication-backup.json',
        bytes: bytes,
        mimeType: 'application/json',
      );
      return location != null || kIsWeb;
    });
  }

  Future<bool> exportHtmlFile({
    required String title,
    required String warning,
  }) {
    final db = ref.read(appDatabaseProvider);
    return _run(() async {
      final bytes = encodeHtmlBackup(
        await db.getAllConfigs(),
        title: title,
        warning: warning,
      );
      final location = await FilePicker.saveFile(
        fileName: 'authentication-backup.html',
        bytes: bytes,
        mimeType: 'text/html',
      );
      return location != null || kIsWeb;
    });
  }

  Future<bool> exportUriFile() {
    final db = ref.read(appDatabaseProvider);
    return _run(() async {
      final bytes = encodeUriList(await db.getAllConfigs());
      final location = await FilePicker.saveFile(
        fileName: 'authentication-uris.txt',
        bytes: bytes,
        mimeType: 'text/plain',
      );
      return location != null || kIsWeb;
    });
  }

  Future<int> importUriFile(Uint8List bytes) {
    final db = ref.read(appDatabaseProvider);
    return _run(
      () async => db.importAccounts(
        decodeUriList(bytes),
        preserveExistingMetadata: true,
      ),
    );
  }

  Future<int> import(Uint8List bytes, String? password) {
    final db = ref.read(appDatabaseProvider);
    return _run(() async {
      final document = await decodeBackupDocument(bytes, password);
      return db.importAccounts(
        document.accounts,
        settings: document.settings,
        integerSettings: document.integerSettings,
        preserveExistingCopyCount: !document.hasCopyCounts,
        importedCategories: document.categories,
        importedMemberships: document.memberships,
      );
    });
  }
}

final backupOperationsProvider =
    NotifierProvider<BackupOperations, AsyncValue<void>>(BackupOperations.new);
