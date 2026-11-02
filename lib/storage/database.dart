import 'package:authentication/otp/account.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/storage/auth_entries.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';
part 'auth_storage.dart';

/// 应用数据库类 (AppDatabase)
///
/// 使用 Drift 框架构建的数据库访问层，负责管理身份验证条目 (AuthEntries) 的持久化操作。
/// 该类通过继承 [_$AppDatabase] 提供对底层数据库的 CRUD（增删改查）访问。
@DriftDatabase(tables: [AuthEntries, AppSettings, AppIntegerSettings])
class AppDatabase extends _$AppDatabase {
  late final EncryptionService encryption;
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'auth_db_v2',
              web: DriftWebOptions(
                sqlite3Wasm: Uri.parse('sqlite3.wasm'),
                driftWorker: Uri.parse('drift_worker.js'),
              ),
            ),
      );

  /// 数据库架构版本号。
  /// 如果修改了表结构，需要递增此版本并处理迁移逻辑。
  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(appSettings);
      if (from < 3) await m.createTable(appIntegerSettings);
      if (from < 4) await m.addColumn(authEntries, authEntries.copyCount);
    },
  );

  Future<void> initializeSettings(Map<String, bool> legacySettings) async {
    final values = validateSettings(legacySettings);
    await transaction(() async {
      for (final entry in values.entries) {
        await into(appSettings).insert(
          AppSettingsCompanion.insert(key: entry.key, value: entry.value),
          mode: InsertMode.insertOrIgnore,
        );
      }
    });
  }

  Future<Map<String, bool>> getSettings() async => {
    ...defaultSettings,
    for (final entry in await select(appSettings).get()) entry.key: entry.value,
  };

  Stream<Map<String, bool>> watchSettings() => select(appSettings).watch().map(
    (entries) => {
      ...defaultSettings,
      for (final entry in entries) entry.key: entry.value,
    },
  );

  Future<void> setSetting(String key, bool value) async {
    if (!defaultSettings.containsKey(key)) {
      throw ArgumentError('Unknown setting');
    }
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion.insert(key: key, value: value),
    );
  }

  Future<Map<String, int>> getIntegerSettings() async =>
      validateIntegerSettings({
        ...defaultIntegerSettings,
        for (final entry in await select(appIntegerSettings).get())
          entry.key: entry.value,
      });

  Stream<Map<String, int>> watchIntegerSettings() =>
      select(appIntegerSettings).watch().map(
        (entries) => validateIntegerSettings({
          ...defaultIntegerSettings,
          for (final entry in entries) entry.key: entry.value,
        }),
      );

  Future<void> setIntegerSetting(String key, int value) async {
    validateIntegerSetting(key, value);
    await into(appIntegerSettings).insertOnConflictUpdate(
      AppIntegerSettingsCompanion.insert(key: key, value: value),
    );
  }

  /// 插入新的身份验证条目。
  ///
  /// [entry] 使用 [AuthEntriesCompanion] 对象，允许只提供非自增字段。
  /// 返回新插入行的自增 ID。
  Future<int> _insertAuthEntry(AuthEntriesCompanion entry) =>
      into(authEntries).insert(entry);

  /// 根据 ID 删除指定的身份验证条目。
  ///
  /// [id] 要删除条目的主键。
  /// 返回受影响的行数。
  Future<int> _deleteAuthEntry(int id) =>
      (delete(authEntries)..where((t) => t.id.equals(id))).go();

  /// 监听所有身份验证条目的实时变化。
  ///
  /// 返回一个 [Stream]，每当数据库表发生变化时都会推送最新的列表。
  Stream<List<AuthEntry>> watchAllAuthEntries() => select(authEntries).watch();

  /// 获取当前所有的身份验证条目列表。
  ///
  /// 执行一次性查询，返回包含所有 [AuthEntry] 的列表。
  Future<List<AuthEntry>> getAllAuthEntries() => select(authEntries).get();

  /// 根据 ID 监听特定身份验证条目的变化。
  ///
  /// [id] 要监听条目的主键。
  /// 如果找不到该 ID，流将推送 null。
  Stream<AuthEntry?> watchAuthEntry(int id) =>
      (select(authEntries)..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// 通过账户名和发行者名称查找唯一的条目。
  ///
  /// [account] 账户名称（如邮箱）。
  /// [issuer] 发行者名称（如 Google）。
  /// 返回匹配的 [AuthEntry] 或 null。
  Future<AuthEntry?> getAuthEntryByAccountAndIssuer(
    String account,
    String issuer,
  ) =>
      (select(authEntries)
            ..where((t) => t.account.equals(account) & t.issuer.equals(issuer)))
          .getSingleOrNull();

  /// 获取数据库中身份验证条目的总数。
  ///
  /// 返回条目的计数值。
  Future<int> countAuthEntries() => authEntries.count().getSingle();
}
