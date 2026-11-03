import 'dart:io';

import 'package:authentication/backup/automatic_backup.dart';
import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/category_provider.dart';
import 'package:authentication/otp/otp_provider.dart';
import 'package:authentication/otp/sorting.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/settings/settings_provider.dart';
import 'package:authentication/widgets/custom_app_bar.dart';
import 'package:authentication/widgets/token_list_item.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 令牌列表主页面，展示所有已保存的身份验证令牌。
class TokenListScreen extends HookConsumerWidget {
  /// 创建令牌列表主页面。
  const TokenListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchController = useTextEditingController();
    final query = useState('');
    final categoryFilter = useState(-1);
    final l10n = AppLocalizations.of(context)!;

    // 监听列表 Provider。每当数据库发生变化时，此流都会更新。
    final authListAsync = ref.watch(authEntryListProvider);
    final categories = ref.watch(categoriesProvider);
    final memberships = ref.watch(categoryMembershipsProvider);
    final backupNeeded = ref.watch(backupNeededProvider).value ?? false;
    final autoBackupStatus = ref.watch(automaticBackupProvider);
    final autoBackupFailed =
        autoBackupStatus == AutomaticBackupStatus.failed ||
        autoBackupStatus == AutomaticBackupStatus.configurationFailed;
    final backupReminders =
        ref.watch(settingsProvider).value?[backupRemindersKey] ?? true;
    final categoryList = categories.value ?? [];
    final selectedCategory =
        categoryFilter.value <= 0 ||
            categoryList.any((c) => c.id == categoryFilter.value)
        ? categoryFilter.value
        : -1;
    final sortMode =
        ref.watch(integerSettingsProvider).value?[sortModeKey] ?? 0;
    final view = ref.watch(integerSettingsProvider).value?[accountViewKey] ?? 0;
    final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    final itemHeight = (view == 1 ? 120.0 : 140.0) + (textScale - 1) * 72;
    final compactCode = view != 0;
    final sortLocked =
        ref.watch(settingsProvider).value?[sortLockedKey] ?? true;
    final busy =
        ref.watch(settingsOperationsProvider).isLoading ||
        ref.watch(accountOperationsProvider).isLoading;
    ref.listen(settingsOperationsProvider, (previous, next) {
      if (next.hasError && context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(l10n.saveFailed)));
      }
    });

    Widget scaffold = Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.appTitle,
        leftIcon: Icons.settings,
        leftOnPressed: (_) => Navigator.pushNamed(context, AppRoutes.settings),
        rightIcon: Icons.add,
        rightOnPressed: (_) => Navigator.pushNamed(context, AppRoutes.add),
      ),
      body: Column(
        children: [
          if (autoBackupFailed)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Material(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(24),
                child: ListTile(
                  title: Text(
                    autoBackupStatus ==
                            AutomaticBackupStatus.configurationFailed
                        ? l10n.autoBackupConfigFailed
                        : l10n.autoBackupFailed,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.automaticBackup),
                ),
              ),
            ),
          if (backupReminders && backupNeeded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Material(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(24),
                child: ListTile(
                  title: Text(l10n.backupReminderMessage),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.pushNamed(context, AppRoutes.add),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: (value) => query.value = value,
                    decoration: InputDecoration(
                      labelText: l10n.search,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: query.value.isEmpty
                          ? null
                          : IconButton(
                              tooltip: l10n.clearSearch,
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                query.value = '';
                              },
                            ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(14)),
                      ),
                    ),
                  ),
                ),
                PopupMenuButton<int>(
                  tooltip: l10n.categoryFilter,
                  icon: Icon(
                    selectedCategory == -1
                        ? Icons.filter_list
                        : Icons.filter_alt,
                  ),
                  initialValue: selectedCategory,
                  onSelected: (value) => categoryFilter.value = value,
                  itemBuilder: (_) => [
                    PopupMenuItem(value: -1, child: Text(l10n.allCategories)),
                    PopupMenuItem(value: 0, child: Text(l10n.uncategorized)),
                    for (final category in categoryList)
                      PopupMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      ),
                  ],
                ),
                PopupMenuButton<int>(
                  tooltip: l10n.sortAccounts,
                  icon: const Icon(Icons.sort),
                  initialValue: sortMode,
                  enabled: !busy,
                  onSelected: (value) => ref
                      .read(settingsOperationsProvider.notifier)
                      .updateInteger(sortModeKey, value),
                  itemBuilder: (_) => [
                    PopupMenuItem(value: 0, child: Text(l10n.sortCustom)),
                    PopupMenuItem(
                      value: 1,
                      child: Text(l10n.sortNameAscending),
                    ),
                    PopupMenuItem(
                      value: 2,
                      child: Text(l10n.sortNameDescending),
                    ),
                    PopupMenuItem(
                      value: 3,
                      child: Text(l10n.sortCopiesAscending),
                    ),
                    PopupMenuItem(
                      value: 4,
                      child: Text(l10n.sortCopiesDescending),
                    ),
                  ],
                ),
                if (sortMode == 0)
                  IconButton(
                    tooltip: sortLocked ? l10n.unlockSorting : l10n.lockSorting,
                    icon: Icon(
                      sortLocked ? Icons.lock_outline : Icons.lock_open,
                    ),
                    onPressed: busy
                        ? null
                        : () => ref
                              .read(settingsOperationsProvider.notifier)
                              .update(sortLockedKey, !sortLocked),
                  ),
              ],
            ),
          ),
          if (selectedCategory != -1)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InputChip(
                label: Text(
                  selectedCategory == 0
                      ? l10n.uncategorized
                      : categoryList
                            .firstWhere((c) => c.id == selectedCategory)
                            .name,
                ),
                onDeleted: () => categoryFilter.value = -1,
              ),
            ),
          if (sortMode == 0 &&
              !sortLocked &&
              (query.value.trim().isNotEmpty || selectedCategory != -1))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                selectedCategory == -1
                    ? l10n.clearSearchToReorder
                    : l10n.clearFilterToReorder,
              ),
            ),
          Expanded(
            child: authListAsync.when(
              data: (data) {
                if (categories.hasError || memberships.hasError) {
                  return Center(child: Text(l10n.categoryLoadFailed));
                }
                if (categories.isLoading || memberships.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (data.isEmpty) {
                  return Center(child: Text(l10n.noData));
                }
                final search = query.value.trim().toLowerCase();
                final filtered = sortAccounts(data, sortMode).where((entry) {
                  final matchesSearch =
                      entry.issuer.toLowerCase().contains(search) ||
                      entry.account.toLowerCase().contains(search);
                  final assigned = memberships.value?[entry.id] ?? <int>{};
                  final matchesCategory =
                      selectedCategory == -1 ||
                      (selectedCategory == 0
                          ? assigned.isEmpty
                          : assigned.contains(selectedCategory));
                  return matchesSearch && matchesCategory;
                }).toList();
                if (filtered.isEmpty) {
                  return Center(child: Text(l10n.noSearchResults));
                }
                if (sortMode == 0 &&
                    !sortLocked &&
                    search.isEmpty &&
                    selectedCategory == -1) {
                  return ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: filtered.length,
                    onReorder: (oldIndex, newIndex) async {
                      if (busy) return;
                      final ids = filtered.map((e) => e.id).toList();
                      if (newIndex > oldIndex) newIndex--;
                      ids.insert(newIndex, ids.removeAt(oldIndex));
                      try {
                        await ref
                            .read(accountOperationsProvider.notifier)
                            .reorder(ids);
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(l10n.reorderFailed)),
                          );
                        }
                      }
                    },
                    itemBuilder: (context, index) {
                      final config = filtered[index];
                      return Padding(
                        key: ValueKey(config.id),
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SizedBox(
                          height: itemHeight,
                          child: Row(
                            children: [
                              Expanded(
                                child: TokenListItem(
                                  key: ValueKey('token_${config.id}'),
                                  config: config,
                                  compact: compactCode,
                                ),
                              ),
                              ReorderableDragStartListener(
                                index: index,
                                enabled: !busy,
                                child: Tooltip(
                                  message: l10n.dragToReorder,
                                  child: SizedBox(
                                    width: 48,
                                    height: itemHeight,
                                    child: const Icon(Icons.drag_handle),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
                return GridView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: view == 2 ? 350 : 700,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: itemHeight,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final config = filtered[index];
                    return TokenListItem(
                      key: ValueKey(config.id),
                      config: config,
                      compact: compactCode,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ),
          ),
        ],
      ),
    );

    if (!kIsWeb && Platform.isAndroid) {
      scaffold = AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: Theme.of(context).colorScheme.surface,
          systemNavigationBarDividerColor: Theme.of(context)
              .colorScheme
              .surface,
          systemNavigationBarIconBrightness: Theme.of(context)
              .colorScheme
              .brightness,
          statusBarColor: Colors.transparent,
          statusBarBrightness: Theme.of(context).colorScheme.brightness,
          statusBarIconBrightness:
              (Theme.of(context).colorScheme.brightness == Brightness.dark)
              ? Brightness.light
              : Brightness.dark,
        ),
        child: scaffold,
      );
    }

    return scaffold;
  }
}
