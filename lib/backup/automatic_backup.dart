import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saf/saf.dart';

const _configKey = 'automatic_backup_config_v1';
final automaticBackupSupportedProvider = Provider<bool>(
  (ref) => !kIsWeb && defaultTargetPlatform == TargetPlatform.android,
);
final automaticBackupStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);
final automaticBackupSafProvider = Provider<Saf>((ref) => Saf());

enum AutomaticBackupStatus {
  loading,
  unsupported,
  disabled,
  ready,
  saving,
  saved,
  failed,
}

final automaticBackupProvider =
    NotifierProvider<AutomaticBackup, AutomaticBackupStatus>(
      AutomaticBackup.new,
    );

class AutomaticBackup extends Notifier<AutomaticBackupStatus> {
  String? _directory;
  String? _password;
  StreamSubscription<int>? _subscription;
  Timer? _timer;
  bool _running = false;
  bool _pending = false;
  int? _latestRevision;
  int? _lastRevision;

  @override
  AutomaticBackupStatus build() {
    ref.onDispose(() {
      _timer?.cancel();
      _subscription?.cancel();
      _password = null;
    });
    if (!ref.watch(automaticBackupSupportedProvider)) {
      return AutomaticBackupStatus.unsupported;
    }
    Future<void>.microtask(_load);
    return AutomaticBackupStatus.loading;
  }

  bool _isLocal(String uri) {
    final parsed = Uri.tryParse(uri);
    return parsed?.scheme == 'content' &&
        parsed?.authority == 'com.android.externalstorage.documents';
  }

  Future<bool> _hasPermission(String uri) async {
    final selected = Uri.parse(uri);
    final segments = selected.pathSegments;
    if (segments.length < 2 || segments.first != 'tree') return false;
    final grants = await ref
        .read(automaticBackupSafProvider)
        .persistedPermissions();
    return grants.any((grant) {
      final target = Uri.tryParse(grant.uri);
      final parts = target?.pathSegments;
      return grant.read &&
          grant.write &&
          target?.authority == selected.authority &&
          parts != null &&
          parts.length == 2 &&
          parts.first == 'tree' &&
          parts[1] == segments[1];
    });
  }

  Future<void> _load() async {
    try {
      final raw = await ref
          .read(automaticBackupStorageProvider)
          .read(key: _configKey);
      if (!ref.mounted) return;
      if (raw == null) {
        state = AutomaticBackupStatus.disabled;
        return;
      }
      final config = jsonDecode(raw);
      if (config is! Map ||
          config['directory'] is! String ||
          config['password'] is! String ||
          !_isLocal(config['directory'] as String) ||
          (config['password'] as String).isEmpty ||
          (config['password'] as String).length > 1024) {
        throw const FormatException();
      }
      _directory = config['directory'] as String;
      _password = config['password'] as String;
      if (!await _hasPermission(_directory!)) throw const FormatException();
      if (!ref.mounted) return;
      state = AutomaticBackupStatus.ready;
      _listen();
    } catch (_) {
      if (ref.mounted) state = AutomaticBackupStatus.failed;
    }
  }

  void _listen() {
    _subscription?.cancel();
    _subscription = ref
        .read(appDatabaseProvider)
        .watchBackupRevision()
        .listen(
          (revision) {
            _latestRevision = revision;
            if (revision != _lastRevision) _schedule();
          },
          onError: (Object _, StackTrace stack) {
            if (ref.mounted) state = AutomaticBackupStatus.failed;
          },
        );
  }

  void _schedule() {
    if (_directory == null || _password == null) return;
    if (_running) {
      _pending = true;
      return;
    }
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 1), () => unawaited(runNow()));
  }

  Future<bool> configure(String password) async {
    if (_running || password.isEmpty || password.length > 1024) return false;
    final previous = state;
    if (_timer?.isActive ?? false) _pending = true;
    _timer?.cancel();
    _running = true;
    state = AutomaticBackupStatus.saving;
    try {
      final picked = await ref.read(automaticBackupSafProvider).pickDirectory();
      if (picked == null) {
        if (ref.mounted) state = previous;
        return false;
      }
      if (!_isLocal(picked.uri)) {
        try {
          await ref
              .read(automaticBackupSafProvider)
              .releasePersistedPermission(picked.uri);
        } catch (_) {}
        throw const FormatException();
      }
      if (!await _hasPermission(picked.uri)) throw const FormatException();
      final config = jsonEncode({
        'directory': picked.uri,
        'password': password,
      });
      final storage = ref.read(automaticBackupStorageProvider);
      await storage.write(key: _configKey, value: config);
      if (await storage.read(key: _configKey) != config) {
        throw StateError('Save failed');
      }
      if (!ref.mounted) return false;
      _directory = picked.uri;
      _password = password;
      _lastRevision = null;
      state = AutomaticBackupStatus.ready;
      _listen();
      return true;
    } catch (_) {
      if (ref.mounted) state = AutomaticBackupStatus.failed;
      return false;
    } finally {
      _running = false;
      if (ref.mounted && _pending && state != AutomaticBackupStatus.failed) {
        _schedule();
      }
    }
  }

  Future<void> disable() async {
    if (_running) return;
    _timer?.cancel();
    _running = true;
    state = AutomaticBackupStatus.saving;
    try {
      await ref.read(automaticBackupStorageProvider).delete(key: _configKey);
      if (await ref
              .read(automaticBackupStorageProvider)
              .read(key: _configKey) !=
          null) {
        throw StateError('Delete failed');
      }
      await _subscription?.cancel();
      _directory = null;
      _password = null;
      _pending = false;
      if (ref.mounted) state = AutomaticBackupStatus.disabled;
    } catch (_) {
      if (ref.mounted) state = AutomaticBackupStatus.failed;
    } finally {
      _running = false;
      if (ref.mounted && _pending && state != AutomaticBackupStatus.failed) {
        _schedule();
      }
    }
  }

  Future<void> runNow() async {
    if (_running || _directory == null || _password == null) return;
    _timer?.cancel();
    _running = true;
    _pending = false;
    state = AutomaticBackupStatus.saving;
    int? snapshotRevision;
    try {
      final db = ref.read(appDatabaseProvider);
      final snapshot = await createBackupSnapshot(db, _password);
      snapshotRevision = snapshot.revision;
      final random = Random.secure();
      final suffix = List.generate(
        16,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
      final saf = ref.read(automaticBackupSafProvider);
      final file = await saf.writeFileStream(
        _directory!,
        'authentication-$suffix.json',
        'application/json',
        Stream.value(snapshot.bytes),
      );
      try {
        final saved = await saf.readFileBytes(
          file.uri,
          count: snapshot.bytes.length + 1,
        );
        if (!listEquals(saved, snapshot.bytes)) {
          throw StateError('Verification failed');
        }
      } catch (_) {
        try {
          await saf.delete(file.uri);
        } catch (_) {}
        rethrow;
      }
      await db.markBackupSaved(snapshot.revision);
      _lastRevision = snapshot.revision;
      if (ref.mounted) state = AutomaticBackupStatus.saved;
    } catch (_) {
      if (ref.mounted) state = AutomaticBackupStatus.failed;
    } finally {
      _running = false;
      if (ref.mounted && _pending && _latestRevision != snapshotRevision) {
        _schedule();
      }
    }
  }
}
