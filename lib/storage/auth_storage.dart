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
  );
}

extension AuthStorage on AppDatabase {
  Stream<List<OtpAccount>> get authConfigsStream => watchAllAuthEntries().map(
    (list) => list.map((e) => _decode(this, e)).toList(),
  );
  Stream<OtpAccount?> watchConfig(int id) =>
      watchAuthEntry(id).map((e) => e == null ? null : _decode(this, e));
  Future<List<OtpAccount>> getAllConfigs() async =>
      (await getAllAuthEntries()).map((e) => _decode(this, e)).toList();
  Future<OtpAccount?> getConfigByAccountAndIssuer(
    String account,
    String issuer,
  ) async {
    final entry = await getAuthEntryByAccountAndIssuer(account, issuer);
    return entry == null ? null : _decode(this, entry);
  }

  Future<void> addConfig(OtpAccount account) async =>
      _insertAuthEntry(_encode(this, account));
  Future<void> updateConfig(OtpAccount account) async {
    final companion = _encode(this, account).copyWith(id: Value(account.id));
    await (update(
      authEntries,
    )..where((t) => t.id.equals(account.id))).write(companion);
  }

  Future<void> deleteConfig(int id) async => _deleteAuthEntry(id);

  Future<int> importAccounts(List<OtpAccount> accounts) async {
    final keys = <String>{};
    for (final account in accounts) {
      account.validate();
      if (!keys.add('${account.issuer}\u0000${account.account}'))
        throw const FormatException('Duplicate accounts in backup.');
    }
    await transaction(() async {
      for (final account in accounts) {
        final existing = await getConfigByAccountAndIssuer(
          account.account,
          account.issuer,
        );
        if (existing == null) {
          await addConfig(account);
        } else {
          await updateConfig(account.copyWith(id: existing.id));
        }
      }
    });
    return accounts.length;
  }
}
