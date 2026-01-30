import 'package:auth/db/auth_entries_ext.dart';
import 'package:auth/db/database.dart';
import 'package:auth/domain/services/otp_service.dart';
import 'package:auth/utils/encryption_service.dart';
import 'package:drift/drift.dart';

/// 批量导入的结果报告
class ImportResult {
  ImportResult({
    required this.successCount,
    required this.failures,
  });

  final int successCount;
  final List<ImportFailure> failures;
}

class ImportFailure {
  ImportFailure(this.source, this.error);
  final String source;
  final String error;
}

class AuthRepository {
  AuthRepository(this.db);

  final AppDatabase db;

  Stream<List<AuthEntry>> get authConfigsStream {
    return db.watchAllAuthEntries().map((list) => list.map(_decryptEntry).toList());
  }

  Stream<AuthEntry?> watchConfig(int id) {
    return db.watchAuthEntry(id).map((entry) => entry != null ? _decryptEntry(entry) : null);
  }

  // --- Helper: Encryption/Decryption ---

  AuthEntry _decryptEntry(AuthEntry entry) {
    return entry.copyWith(secret: EncryptionService.decrypt(entry.secret));
  }

  AuthEntriesCompanion _encryptCompanion(AuthEntriesCompanion companion) {
    if (companion.secret.present) {
      return companion.copyWith(
        secret: Value(EncryptionService.encrypt(companion.secret.value)),
      );
    }
    return companion;
  }

  AuthEntry _encryptEntry(AuthEntry entry) {
    return entry.copyWith(secret: EncryptionService.encrypt(entry.secret));
  }

  // --- CRUD Actions ---

  Future<void> addConfig(AuthEntriesCompanion companion) async {
    await db.insertAuthEntry(_encryptCompanion(companion));
  }

  Future<void> insertCompanion(AuthEntriesCompanion companion) async {
    await db.insertAuthEntry(_encryptCompanion(companion));
  }

  Future<void> updateConfig(AuthEntry entry) async {
    await db.updateAuthEntry(_encryptEntry(entry));
  }

  Future<void> deleteConfig(int id) async {
    await db.deleteAuthEntry(id);
  }

  Future<List<AuthEntry>> getAllConfigs() async {
    final list = await db.getAllAuthEntries();
    return list.map(_decryptEntry).toList();
  }

  Future<AuthEntry?> getConfigByAccountAndIssuer(
    String account,
    String issuer,
  ) async {
    final entry = await db.getAuthEntryByAccountAndIssuer(account, issuer);
    return entry != null ? _decryptEntry(entry) : null;
  }

  /// Batch import from text (e.g. clipboard).
  /// Returns a detailed result report.
  Future<ImportResult> importBatch(String text) async {
    int successCount = 0;
    final List<ImportFailure> failures = [];
    final List<String> optUrls = OtpService.splitUriList(text);

    for (final String optUrl in optUrls) {
      try {
        final AuthEntriesCompanion config = AuthEntryUtils.parse(optUrl);
        final existing = await getConfigByAccountAndIssuer(
          config.account.value,
          config.issuer.value,
        );

        if (existing != null) {
          final updatedEntry = existing.copyWithCompanion(config);
          await updateConfig(updatedEntry);
        } else {
          await addConfig(config);
        }
        successCount++;
      } catch (e) {
        failures.add(ImportFailure(optUrl, e.toString()));
      }
    }
    return ImportResult(successCount: successCount, failures: failures);
  }
}