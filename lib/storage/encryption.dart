import 'package:authentication/storage/database.dart';
import 'package:encrypt/encrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encrypts database fields with a device-specific key held by the platform.
class EncryptionService {
  static const _prefix = 'enc:v1:';
  static const _storageKey = 'database_encryption_key_v1';
  EncryptionService._(this._encrypter);
  final Encrypter _encrypter;

  /// Initializes the device key and verifies stored entries.
  /// A missing key must never be silently replaced when encrypted data exists.
  static Future<EncryptionService> initialize(
    AppDatabase db, {
    FlutterSecureStorage? storage,
  }) async {
    final secureStorage =
        storage ??
        const FlutterSecureStorage(
          mOptions: MacOsOptions(usesDataProtectionKeychain: false),
        );
    final entries = await db.getAllAuthEntries();
    var storedKey = await secureStorage.read(key: _storageKey);
    if (storedKey == null) {
      if (entries.any(
        (e) => e.secret.startsWith(_prefix) || e.pin.startsWith(_prefix),
      )) {
        throw StateError(
          'The encryption key is unavailable. Restore it before opening this database.',
        );
      }
      storedKey = Key.fromSecureRandom(32).base64;
      await secureStorage.write(key: _storageKey, value: storedKey);
      if (await secureStorage.read(key: _storageKey) != storedKey) {
        throw StateError('Unable to persist the database encryption key.');
      }
    }
    final key = Key.fromBase64(storedKey);
    if (key.bytes.length != 32)
      throw StateError('Invalid database encryption key.');
    final service = EncryptionService._(Encrypter(AES(key, mode: AESMode.gcm)));

    for (final entry in entries) {
      service.decrypt(entry.secret);
      service.decrypt(entry.pin);
    }
    return service;
  }

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
