part of 'database.dart';

OtpAccount _decode(AppDatabase db, AuthEntry e) => OtpAccount(
  id: e.id,
  type: e.type,
  issuer: e.issuer,
  account: e.account,
  secret: db.encryption.decrypt(e.secret),
  algorithm: e.algorithm,
  digits: e.digits,
  period: e.period,
  counter: e.counter,
  pin: db.encryption.decrypt(e.pin),
  icon: e.icon,
  sortOrder: e.sortOrder,
  createdAt: e.createdAt,
  copyCount: e.copyCount,
);

AuthEntriesCompanion _encode(AppDatabase db, OtpAccount e) {
  e.validate();
  return AuthEntriesCompanion.insert(
    scheme: 'otpauth',
    type: e.type,
    issuer: e.issuer,
    account: e.account,
    secret: db.encryption.encrypt(e.secret),
    algorithm: e.algorithm,
    digits: e.digits,
    period: e.period,
    counter: e.counter,
    pin: db.encryption.encrypt(e.pin),
    icon: e.icon,
    sortOrder: e.sortOrder,
    createdAt: e.createdAt,
    copyCount: Value(e.copyCount),
  );
}

extension AuthStorage on AppDatabase {
  Stream<List<OtpAccount>> get authConfigsStream => watchAllAuthEntries().map(
    (list) => list.map((e) => _decode(this, e)).toList(),
  );
  Stream<OtpAccount?> watchConfig(int id) =>
      watchAuthEntry(id).map((e) => e == null ? null : _decode(this, e));
  Future<OtpAccount?> getConfig(int id) async {
    final entry = await (select(
      authEntries,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return entry == null ? null : _decode(this, entry);
  }

  Future<List<OtpAccount>> getAllConfigs() async =>
      (await getAllAuthEntries()).map((e) => _decode(this, e)).toList();
  Future<OtpAccount?> getConfigByAccountAndIssuer(
    String account,
    String issuer,
  ) async {
    final entry = await getAuthEntryByAccountAndIssuer(account, issuer);
    return entry == null ? null : _decode(this, entry);
  }

  Future<void> addConfig(
    OtpAccount account, {
    bool preserveSortOrder = false,
  }) async {
    await transaction(() async {
      if (preserveSortOrder) {
        await _insertAuthEntry(_encode(this, account));
        return;
      }
      final entries = await getAllAuthEntries();
      final next =
          entries.fold<int>(
            -1,
            (max, e) => e.sortOrder > max ? e.sortOrder : max,
          ) +
          1;
      await _insertAuthEntry(_encode(this, account.copyWith(sortOrder: next)));
    });
  }

  Future<void> updateConfig(OtpAccount account) async {
    final companion = _encode(this, account).copyWith(
      id: Value(account.id),
      copyCount: const Value.absent(),
      sortOrder: const Value.absent(),
    );
    await (update(
      authEntries,
    )..where((t) => t.id.equals(account.id))).write(companion);
  }

  Future<void> deleteConfig(int id) async => _deleteAuthEntry(id);

  Future<void> reorderAccounts(List<int> ids) async {
    await transaction(() async {
      final current = await getAllAuthEntries();
      final existing = current.map((e) => e.id).toSet();
      if (ids.length != existing.length ||
          ids.toSet().length != ids.length ||
          !ids.every(existing.contains)) {
        throw StateError('Account list changed during sorting.');
      }
      for (var index = 0; index < ids.length; index++) {
        await (update(authEntries)..where((t) => t.id.equals(ids[index])))
            .write(AuthEntriesCompanion(sortOrder: Value(index)));
      }
    });
  }

  Future<void> recordCopy(
    OtpAccount copied, {
    required bool advanceHotp,
  }) async {
    await transaction(() async {
      final current = await getConfig(copied.id);
      if (current == null ||
          current.type != copied.type ||
          current.secret != copied.secret ||
          current.pin != copied.pin ||
          current.algorithm != copied.algorithm ||
          current.digits != copied.digits ||
          current.period != copied.period ||
          current.counter != copied.counter) {
        throw StateError('Account changed during copy.');
      }
      final nextCounter = advanceHotp && current.type.toLowerCase() == 'hotp'
          ? current.counter + 1
          : current.counter;
      current
          .copyWith(counter: nextCounter, copyCount: current.copyCount + 1)
          .validate();
      await (update(authEntries)..where((t) => t.id.equals(current.id))).write(
        AuthEntriesCompanion(
          counter: Value(nextCounter),
          copyCount: Value(current.copyCount + 1),
        ),
      );
    });
  }

  Future<void> resetCopyCount(int id) async {
    await (update(authEntries)..where((t) => t.id.equals(id))).write(
      const AuthEntriesCompanion(copyCount: Value(0)),
    );
  }

  Future<void> advanceHotp(int id) async {
    await transaction(() async {
      final current = await getConfig(id);
      if (current == null || current.type.toLowerCase() != 'hotp') {
        throw StateError('HOTP account not found.');
      }
      await updateConfig(current.copyWith(counter: current.counter + 1));
    });
  }

  Future<int> importAccounts(
    List<OtpAccount> accounts, {
    bool preserveExistingMetadata = false,
    bool preserveExistingCopyCount = false,
    Map<String, bool>? settings,
    Map<String, int>? integerSettings,
  }) async {
    final keys = <(String, String)>{};
    for (final account in accounts) {
      account.validate();
      if (!keys.add((account.issuer, account.account)))
        throw const FormatException('Duplicate accounts in backup.');
    }
    final validatedSettings = settings == null
        ? null
        : validateSettings(settings);
    final validatedIntegers = integerSettings == null
        ? null
        : validateIntegerSettings(integerSettings);
    await transaction(() async {
      if (validatedIntegers != null) {
        for (final setting in validatedIntegers.entries) {
          await setIntegerSetting(setting.key, setting.value);
        }
      }
      if (validatedSettings != null) {
        for (final setting in validatedSettings.entries) {
          await setSetting(setting.key, setting.value);
        }
      }
      for (final account in accounts) {
        final existing = await getConfigByAccountAndIssuer(
          account.account,
          account.issuer,
        );
        if (existing == null) {
          await addConfig(
            account,
            preserveSortOrder: !preserveExistingMetadata,
          );
        } else {
          await updateConfig(
            account.copyWith(
              id: existing.id,
              icon: preserveExistingMetadata ? existing.icon : account.icon,
              sortOrder: preserveExistingMetadata
                  ? existing.sortOrder
                  : account.sortOrder,
              createdAt: preserveExistingMetadata
                  ? existing.createdAt
                  : account.createdAt,
              copyCount: preserveExistingCopyCount || preserveExistingMetadata
                  ? existing.copyCount
                  : account.copyCount,
            ),
          );
          if (!preserveExistingMetadata) {
            await (update(
              authEntries,
            )..where((t) => t.id.equals(existing.id))).write(
              AuthEntriesCompanion(sortOrder: Value(account.sortOrder)),
            );
          }
          if (!preserveExistingCopyCount && !preserveExistingMetadata) {
            await (update(
              authEntries,
            )..where((t) => t.id.equals(existing.id))).write(
              AuthEntriesCompanion(copyCount: Value(account.copyCount)),
            );
          }
        }
      }
    });
    return accounts.length;
  }
}
