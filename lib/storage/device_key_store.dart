import 'dart:typed_data';

import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/password_key.dart';
import 'package:drift/drift.dart' show Variable;
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const legacyDeviceKey = 'database_encryption_key_v1';
const _wrappedPrefix = 'password:v1:';
const _slotPrefix = 'database_encryption_key_slot_';

/// The new key is active, but removal of the previous slot failed.
class KeyChangeCleanupFailed implements Exception {
  const KeyChangeCleanupFailed();
}

/// Password envelopes and the platform-protected key slots refer to the same
/// account encryption key. The database pointer selects exactly one slot.
class DeviceKeyStore {
  DeviceKeyStore(this.database, this.storage);
  final AppDatabase database;
  final FlutterSecureStorage storage;

  Future<({String? active, String? previous, String? pending})> _state() async {
    final row = await database
        .customSelect(
          'SELECT active, previous, pending FROM key_state WHERE id = 1',
        )
        .getSingle();
    final active = row.readNullable<String>('active');
    final previous = row.readNullable<String>('previous');
    final pending = row.readNullable<String>('pending');
    bool valid(String? value) =>
        value == null ||
        value == legacyDeviceKey ||
        RegExp(r'^database_encryption_key_slot_[0-9a-f]{32}$').hasMatch(value);
    if (!valid(active) ||
        !valid(previous) ||
        !valid(pending) ||
        (pending != null &&
            (pending == legacyDeviceKey ||
                pending == active ||
                pending == previous)) ||
        (previous != null && previous == (active ?? legacyDeviceKey))) {
      throw StateError('Invalid key state.');
    }
    return (active: active, previous: previous, pending: pending);
  }

  Future<bool> requiresPassword() async {
    final state = await _state();
    final value = await storage.read(key: state.active ?? legacyDeviceKey);
    if (state.active != null && value == null) {
      throw StateError('The encryption key is unavailable.');
    }
    return value?.startsWith(_wrappedPrefix) ?? false;
  }

  Future<Uint8List?> readKey({
    String? password,
    bool requirePassword = false,
  }) async {
    final state = await _state();
    final value = await storage.read(key: state.active ?? legacyDeviceKey);
    if (value == null) {
      if (state.active != null) {
        throw StateError('The encryption key is unavailable.');
      }
      return null;
    }
    if (requirePassword && !value.startsWith(_wrappedPrefix)) return null;
    final key = value.startsWith(_wrappedPrefix)
        ? await unwrapDeviceKey(
            value.substring(_wrappedPrefix.length),
            password ?? '',
          )
        : Key.fromBase64(value).bytes;
    if (key.length != 32) throw StateError('Invalid encryption key.');
    return Uint8List.fromList(key);
  }

  Future<void> cleanupPrevious({bool removePending = true}) =>
      database.transaction(() async {
        await database.customStatement(
          'UPDATE key_state SET id = id WHERE id = 1',
        );
        final state = await _state();
        final pending = state.pending;
        if (pending != null && !removePending) {
          throw StateError('A key change is in progress.');
        }
        if (pending != null) {
          await storage.delete(key: pending);
          if (await storage.read(key: pending) != null) {
            throw StateError('Unable to remove pending key.');
          }
          await database.customUpdate(
            'UPDATE key_state SET pending = NULL WHERE id = 1 AND pending = ?',
            variables: [Variable.withString(pending)],
          );
        }
        final previous = state.previous;
        if (previous == null) return;
        await storage.delete(key: previous);
        if (await storage.read(key: previous) != null) {
          throw StateError('Unable to remove old key.');
        }
        await database.customUpdate(
          'UPDATE key_state SET previous = NULL WHERE id = 1 AND previous = ?',
          variables: [Variable.withString(previous)],
        );
      });

  Future<void> changePassword({
    required Uint8List deviceKey,
    String? currentPassword,
    String? newPassword,
  }) async {
    if (deviceKey.length != 32) throw const FormatException('Invalid key.');
    final before = await _state();
    final current = await readKey(password: currentPassword);
    if (current == null || !listEquals(current, deviceKey)) {
      throw StateError('The encryption key changed.');
    }
    await cleanupPrevious(removePending: false);
    final value = newPassword == null
        ? Key(deviceKey).base64
        : '$_wrappedPrefix${await wrapDeviceKey(deviceKey, newPassword)}';
    if (newPassword != null &&
        !listEquals(
          await unwrapDeviceKey(
            value.substring(_wrappedPrefix.length),
            newPassword,
          ),
          deviceKey,
        )) {
      throw StateError('Unable to verify key.');
    }
    final suffix = Key.fromSecureRandom(16).bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
    final slot = '$_slotPrefix$suffix';
    final reserved = await database.customUpdate(
      'UPDATE key_state SET pending = ? WHERE id = 1 AND active IS ? AND previous IS NULL AND pending IS NULL',
      variables: [Variable.withString(slot), Variable<String>(before.active)],
    );
    if (reserved != 1) {
      throw StateError('The encryption key changed.');
    }
    await database.transaction(() async {
      await database.customStatement(
        'UPDATE key_state SET id = id WHERE id = 1',
      );
      final reservedState = await _state();
      if (reservedState.active != before.active ||
          reservedState.pending != slot) {
        throw StateError('The encryption key changed.');
      }
      await storage.write(key: slot, value: value);
      if (await storage.read(key: slot) != value) {
        throw StateError('Unable to persist key.');
      }
      final updated = await database.customUpdate(
        'UPDATE key_state SET active = ?, previous = ?, pending = NULL WHERE id = 1 AND active IS ? AND pending = ?',
        variables: [
          Variable.withString(slot),
          Variable.withString(before.active ?? legacyDeviceKey),
          Variable<String>(before.active),
          Variable.withString(slot),
        ],
      );
      if (updated != 1) throw StateError('The encryption key changed.');
    });
    try {
      await cleanupPrevious();
    } catch (_) {
      throw const KeyChangeCleanupFailed();
    }
  }
}
