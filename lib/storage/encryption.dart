import 'dart:typed_data';

import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/device_key_store.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypts database fields with a device-specific key held by the platform.
class EncryptionService {
  static const _prefix = 'enc:v1:';
  static const _storageKey = 'database_encryption_key_v1';
  EncryptionService._(this._encrypter, this._key, this._store);
  final Encrypter _encrypter;
  final Uint8List _key;
  final DeviceKeyStore _store;

  /// Initializes the device key and verifies stored entries.
  /// A missing key must never be silently replaced when encrypted data exists.
  static Future<EncryptionService> initialize(
    AppDatabase db, {
    FlutterSecureStorage? storage,
    String? password,
  }) async {
    final secureStorage =
        storage ??
        const FlutterSecureStorage(
          mOptions: MacOsOptions(usesDataProtectionKeychain: false),
        );
    final entries = await db.getAllAuthEntries();
    final store = DeviceKeyStore(db, secureStorage);
    var keyBytes = await store.readKey(password: password);
    if (keyBytes == null) {
      if (entries.any(
        (e) => e.secret.startsWith(_prefix) || e.pin.startsWith(_prefix),
      )) {
        throw StateError(
          'The encryption key is unavailable. Restore it before opening this database.',
        );
      }
      final storedKey = Key.fromSecureRandom(32).base64;
      await secureStorage.write(key: _storageKey, value: storedKey);
      if (await secureStorage.read(key: _storageKey) != storedKey) {
        throw StateError('Unable to persist the database encryption key.');
      }
      keyBytes = Key.fromBase64(storedKey).bytes;
    }
    final key = Key(keyBytes);
    if (key.bytes.length != 32)
      throw StateError('Invalid database encryption key.');
    final service = EncryptionService._(
      Encrypter(AES(key, mode: AESMode.gcm)),
      Uint8List.fromList(key.bytes),
      store,
    );

    for (final entry in entries) {
      service.decrypt(entry.secret);
      service.decrypt(entry.pin);
    }
    await store.cleanupPrevious();
    return service;
  }

  Future<bool> get passwordEnabled => _store.requiresPassword();

  /// Verifies the current password without retaining it or changing the key.
  Future<bool> verifyPassword(String password) async {
    Uint8List? candidate;
    try {
      candidate = await _store.readKey(
        password: password,
        requirePassword: true,
      );
      return candidate != null && listEquals(candidate, _key);
    } on FormatException {
      return false;
    } finally {
      candidate?.fillRange(0, candidate.length, 0);
    }
  }

  Future<void> changePassword({String? currentPassword, String? newPassword}) =>
      _store.changePassword(
        deviceKey: _key,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

  String encrypt(String plainText) {
    if (plainText.isEmpty) return '';
    final encrypter = _encrypter;
    final iv = IV.fromSecureRandom(12);
    return '$_prefix${iv.base64}:${encrypter.encrypt(plainText, iv: iv).base64}';
  }

  String decrypt(String encryptedText) {
    if (encryptedText.isEmpty) return '';
    final encrypter = _encrypter;
    if (!encryptedText.startsWith(_prefix))
      throw StateError('Unencrypted database field.');
    final parts = encryptedText.substring(_prefix.length).split(':');
    if (parts.length != 2)
      throw const FormatException('Invalid encrypted field.');
    return encrypter.decrypt64(parts[1], iv: IV.fromBase64(parts[0]));
  }
}
