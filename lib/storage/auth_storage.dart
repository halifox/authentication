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
  validateIcon(e.icon);
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
    bool applyDefaultCategory = true,
  }) async {
    await transaction(() async {
      if (preserveSortOrder) {
        final id = await _insertAuthEntry(_encode(this, account));
        if (applyDefaultCategory) await _assignDefaultCategory(id);
        return;
      }
      final entries = await getAllAuthEntries();
      final next =
          entries.fold<int>(
            -1,
            (max, e) => e.sortOrder > max ? e.sortOrder : max,
          ) +
          1;
      final id = await _insertAuthEntry(
        _encode(this, account.copyWith(sortOrder: next)),
      );
      if (applyDefaultCategory) await _assignDefaultCategory(id);
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

  Future<void> _assignDefaultCategory(int accountId) async {
    final defaults = (await getCategories())
        .where((category) => category.isDefault)
        .toList();
    if (defaults.length > 1) throw StateError('Multiple default categories.');
    if (defaults.isNotEmpty) {
      await into(accountCategoryLinks).insert(
        AccountCategoryLinksCompanion.insert(
          accountId: accountId,
          categoryId: defaults.single.id,
        ),
      );
    }
  }

  Future<void> deleteConfig(int id) async => transaction(() async {
    await (delete(
      accountCategoryLinks,
    )..where((link) => link.accountId.equals(id))).go();
    await _deleteAuthEntry(id);
  });

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
    List<AccountCategory>? importedCategories,
    Map<(String, String), List<String>>? importedMemberships,
    bool mergeImportedMemberships = false,
    List<IconPack>? importedIconPacks,
  }) async {
    if (importedIconPacks != null) validateIconPacks(importedIconPacks);
    final keys = <(String, String)>{};
    for (final account in accounts) {
      account.validate();
      validateIcon(account.icon);
      if (!keys.add((account.issuer, account.account))) {
        throw const FormatException('Duplicate accounts in backup.');
      }
    }
    final validatedSettings = settings == null
        ? null
        : validateSettings(settings);
    final validatedIntegers = integerSettings == null
        ? null
        : validateIntegerSettings(integerSettings);
    final checkedCategories = importedCategories == null
        ? null
        : validateCategories(importedCategories);
    if ((checkedCategories == null) != (importedMemberships == null)) {
      throw const FormatException('Missing category membership.');
    }
    if (mergeImportedMemberships &&
        (checkedCategories == null ||
            checkedCategories.any((c) => c.isDefault))) {
      throw const FormatException('Invalid category merge.');
    }
    if (checkedCategories != null) {
      final names = checkedCategories.map((c) => c.name).toSet();
      if (importedMemberships!.length != accounts.length ||
          accounts.any(
            (a) => !importedMemberships.containsKey((a.issuer, a.account)),
          ) ||
          importedMemberships.values.any(
            (list) =>
                list.toSet().length != list.length ||
                list.any((n) => !names.contains(n)),
          )) {
        throw const FormatException('Invalid category membership.');
      }
    }
    await transaction(() async {
      if (importedIconPacks != null) {
        for (final pack in importedIconPacks) {
          await saveIconPack(pack);
        }
      }
      var categoryIds = <String, int>{};
      if (checkedCategories != null) {
        final local = {
          for (final category in await getCategories()) category.name: category,
        };
        if ({...local.keys, ...checkedCategories.map((c) => c.name)}.length >
            1000) {
          throw const FormatException('Too many categories.');
        }
        var nextOrder =
            local.values.fold<int>(
              -1,
              (max, category) =>
                  category.sortOrder > max ? category.sortOrder : max,
            ) +
            1;
        if (!mergeImportedMemberships) {
          await update(categories)
              .write(const CategoriesCompanion(isDefault: Value(false)));
        }
        for (final category in checkedCategories) {
          final existing = local[category.name];
          if (existing == null) {
            await into(categories).insert(
              CategoriesCompanion.insert(
                name: category.name,
                sortOrder: mergeImportedMemberships
                    ? nextOrder++
                    : category.sortOrder,
                isDefault: Value(category.isDefault),
              ),
            );
          } else if (!mergeImportedMemberships) {
            await (update(
              categories,
            )..where((c) => c.id.equals(existing.id))).write(
              CategoriesCompanion(
                sortOrder: Value(category.sortOrder),
                isDefault: Value(category.isDefault),
              ),
            );
          }
        }
        categoryIds = {
          for (final category in await getCategories())
            category.name: category.id,
        };
      }
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
            applyDefaultCategory:
                checkedCategories == null || mergeImportedMemberships,
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
        if (checkedCategories != null) {
          final saved = await getConfigByAccountAndIssuer(
            account.account,
            account.issuer,
          );
          if (saved == null) throw StateError('Imported account not found.');
          if (!mergeImportedMemberships) {
            await (delete(
              accountCategoryLinks,
            )..where((link) => link.accountId.equals(saved.id))).go();
          }
          for (final name
              in importedMemberships![(account.issuer, account.account)]!) {
            await into(accountCategoryLinks).insert(
              AccountCategoryLinksCompanion.insert(
                accountId: saved.id,
                categoryId: categoryIds[name]!,
              ),
              mode: mergeImportedMemberships
                  ? InsertMode.insertOrIgnore
                  : InsertMode.insert,
            );
          }
        }
      }
    });
    return accounts.length;
  }
}
