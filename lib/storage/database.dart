import 'dart:convert';

import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/category.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/storage/auth_entries.dart';
import 'package:authentication/storage/encryption.dart';
import 'package:authentication/storage/icon_data.dart';
import 'package:authentication/storage/icon_pack.dart';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'database.g.dart';
part 'auth_storage.dart';

class ImportPreviewExpired implements Exception {
  const ImportPreviewExpired();
}

/// 应用数据库类 (AppDatabase)
///
/// 使用 Drift 框架构建的数据库访问层，负责管理身份验证条目 (AuthEntries) 的持久化操作。
/// 该类通过继承 [_$AppDatabase] 提供对底层数据库的 CRUD（增删改查）访问。
@DriftDatabase(
  tables: [
    AuthEntries,
    AppSettings,
    AppIntegerSettings,
    Categories,
    AccountCategoryLinks,
    BackupState,
    IconPacks,
  ],
)
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
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _initializeBackupTracking(false);
      await _createIconPackTriggers();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) await m.createTable(appSettings);
      if (from < 3) await m.createTable(appIntegerSettings);
      if (from < 4) await m.addColumn(authEntries, authEntries.copyCount);
      if (from < 5) {
        await m.createTable(categories);
        await m.createTable(accountCategoryLinks);
      }
      if (from < 6) {
        await m.createTable(backupState);
        await _initializeBackupTracking(true);
      }
      if (from < 7) {
        await m.createTable(iconPacks);
        await _createIconPackTriggers();
      }
    },
  );

  Future<void> _initializeBackupTracking(bool existing) async {
    await customStatement(
      'INSERT INTO backup_state (id, revision, saved_revision) VALUES (1, ${existing ? 1 : 0}, 0)',
    );
    for (final table in [
      'auth_entries',
      'app_settings',
      'app_integer_settings',
      'categories',
      'account_category_links',
    ]) {
      for (final operation in ['INSERT', 'UPDATE', 'DELETE']) {
        await customStatement(
          'CREATE TRIGGER backup_${table}_${operation.toLowerCase()} AFTER $operation ON $table BEGIN UPDATE backup_state SET revision = revision + 1 WHERE id = 1; END',
        );
      }
    }
  }

  Future<void> _createIconPackTriggers() async {
    for (final operation in ['INSERT', 'UPDATE', 'DELETE']) {
      await customStatement(
        'CREATE TRIGGER backup_icon_packs_${operation.toLowerCase()} AFTER $operation ON icon_packs BEGIN UPDATE backup_state SET revision = revision + 1 WHERE id = 1; END',
      );
    }
  }

  Future<List<IconPack>> getIconPacks() async => [
    for (final row in await select(iconPacks).get())
      iconPackFromJson(jsonDecode(row.data)),
  ];

  Stream<List<IconPack>> watchIconPacks() => select(iconPacks).watch().map(
    (rows) => [for (final row in rows) iconPackFromJson(jsonDecode(row.data))],
  );

  Future<void> saveIconPack(IconPack pack) async {
    validateIconPack(pack);
    final encoded = jsonEncode(iconPackToJson(pack));
    await transaction(() async {
      final existing = await select(iconPacks).get();
      final others = existing.where((row) => row.name != pack.name).toList();
      if (others.length >= 100 ||
          others.fold<int>(
                encoded.length,
                (sum, row) => sum + row.data.length,
              ) >
              maxStoredIconPacksBytes) {
        throw const FormatException('Icon packs are too large.');
      }
      await into(iconPacks).insertOnConflictUpdate(
        IconPacksCompanion.insert(name: pack.name, data: encoded),
      );
    });
  }

  Future<void> deleteIconPack(String name) async {
    await (delete(iconPacks)..where((row) => row.name.equals(name))).go();
  }

  Future<int> backupRevision() async =>
      (await select(backupState).getSingle()).revision;

  Future<void> markBackupSaved(int revision) async {
    await (update(backupState)..where((row) => row.id.equals(1))).write(
      BackupStateCompanion(savedRevision: Value(revision)),
    );
  }

  Stream<bool> watchBackupNeeded() => customSelect(
    'SELECT revision != saved_revision AND (saved_revision > 0 OR EXISTS (SELECT 1 FROM auth_entries) OR EXISTS (SELECT 1 FROM categories) OR EXISTS (SELECT 1 FROM icon_packs)) AS needed FROM backup_state WHERE id = 1',
    readsFrom: {
      backupState,
      authEntries,
      appSettings,
      appIntegerSettings,
      categories,
      accountCategoryLinks,
      iconPacks,
    },
  ).watchSingle().map((row) => row.read<bool>('needed'));

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

  AccountCategory _category(CategoryRow row) => AccountCategory(
    id: row.id,
    name: row.name,
    sortOrder: row.sortOrder,
    isDefault: row.isDefault,
  );

  Stream<List<AccountCategory>> watchCategories() =>
      (select(categories)..orderBy([
            (c) => OrderingTerm.asc(c.sortOrder),
            (c) => OrderingTerm.asc(c.id),
          ]))
          .watch()
          .map((rows) => rows.map(_category).toList());

  Future<List<AccountCategory>> getCategories() async =>
      (await (select(categories)..orderBy([
                (c) => OrderingTerm.asc(c.sortOrder),
                (c) => OrderingTerm.asc(c.id),
              ]))
              .get())
          .map(_category)
          .toList();

  Future<void> createCategory(String name) async {
    final valid = validateCategoryName(name);
    await transaction(() async {
      final existing = await getCategories();
      if (existing.length >= 1000) {
        throw const FormatException('Too many categories.');
      }
      final order =
          existing.fold<int>(
            -1,
            (max, c) => c.sortOrder > max ? c.sortOrder : max,
          ) +
          1;
      await into(categories)
          .insert(CategoriesCompanion.insert(name: valid, sortOrder: order));
    });
  }

  Future<void> renameCategory(int id, String name) async {
    final valid = validateCategoryName(name);
    final count = await (update(categories)..where((c) => c.id.equals(id)))
        .write(CategoriesCompanion(name: Value(valid)));
    if (count != 1) throw StateError('Category not found.');
  }

  Future<void> deleteCategory(int id) async {
    await transaction(() async {
      await (delete(
        accountCategoryLinks,
      )..where((link) => link.categoryId.equals(id))).go();
      final count = await (delete(
        categories,
      )..where((c) => c.id.equals(id))).go();
      if (count != 1) throw StateError('Category not found.');
    });
  }

  Stream<Map<int, Set<int>>> watchCategoryMemberships() =>
      select(accountCategoryLinks).watch().map((rows) {
        final result = <int, Set<int>>{};
        for (final row in rows) {
          (result[row.accountId] ??= {}).add(row.categoryId);
        }
        return result;
      });

  Future<Map<int, Set<int>>> getCategoryMemberships() async {
    final result = <int, Set<int>>{};
    for (final row in await select(accountCategoryLinks).get()) {
      (result[row.accountId] ??= {}).add(row.categoryId);
    }
    return result;
  }

  Future<void> setAccountCategories(
    int accountId,
    Set<int> categoryIds, {
    Set<int>? expected,
  }) async {
    await transaction(() async {
      if (expected != null) {
        final current = (await getCategoryMemberships())[accountId] ?? <int>{};
        if (current.length != expected.length ||
            !current.containsAll(expected)) {
          throw StateError('Category membership changed.');
        }
      }
      if (await getConfig(accountId) == null) {
        throw StateError('Account not found.');
      }
      final validIds = (await getCategories()).map((c) => c.id).toSet();
      if (!categoryIds.every(validIds.contains)) {
        throw const FormatException('Category not found.');
      }
      await (delete(
        accountCategoryLinks,
      )..where((link) => link.accountId.equals(accountId))).go();
      for (final id in categoryIds) {
        await into(accountCategoryLinks).insert(
          AccountCategoryLinksCompanion.insert(
            accountId: accountId,
            categoryId: id,
          ),
        );
      }
    });
  }

  Future<void> setCategoryAccounts(
    int categoryId,
    Set<int> accountIds, {
    Set<int>? expected,
  }) async {
    await transaction(() async {
      if (expected != null) {
        final current = {
          for (final entry in (await getCategoryMemberships()).entries)
            if (entry.value.contains(categoryId)) entry.key,
        };
        if (current.length != expected.length ||
            !current.containsAll(expected)) {
          throw StateError('Category membership changed.');
        }
      }
      if (!(await getCategories()).any((c) => c.id == categoryId)) {
        throw StateError('Category not found.');
      }
      final validIds = (await getAllAuthEntries()).map((a) => a.id).toSet();
      if (!accountIds.every(validIds.contains)) {
        throw const FormatException('Account not found.');
      }
      await (delete(
        accountCategoryLinks,
      )..where((link) => link.categoryId.equals(categoryId))).go();
      for (final id in accountIds) {
        await into(accountCategoryLinks).insert(
          AccountCategoryLinksCompanion.insert(
            accountId: id,
            categoryId: categoryId,
          ),
        );
      }
    });
  }

  Future<void> setDefaultCategory(int? id) async {
    await transaction(() async {
      if (id != null && !(await getCategories()).any((c) => c.id == id)) {
        throw StateError('Category not found.');
      }
      await update(categories)
          .write(const CategoriesCompanion(isDefault: Value(false)));
      if (id != null) {
        await (update(categories)..where((c) => c.id.equals(id))).write(
          const CategoriesCompanion(isDefault: Value(true)),
        );
      }
    });
  }

  Future<void> reorderCategories(List<int> ids) async {
    await transaction(() async {
      final existing = (await getCategories()).map((c) => c.id).toSet();
      if (ids.length != existing.length ||
          ids.toSet().length != ids.length ||
          !ids.every(existing.contains)) {
        throw StateError('Category list changed.');
      }
      for (var i = 0; i < ids.length; i++) {
        await (update(categories)..where((c) => c.id.equals(ids[i]))).write(
          CategoriesCompanion(sortOrder: Value(i)),
        );
      }
    });
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
