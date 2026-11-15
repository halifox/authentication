import 'package:authentication/backup/automatic_backup.dart';
import 'package:authentication/backup/backup_provider.dart';
import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/category_provider.dart';
import 'package:authentication/otp/otp_provider.dart';
import 'package:authentication/otp/sorting.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/settings/settings.dart';
import 'package:authentication/settings/settings_provider.dart';
import 'package:authentication/widgets/app_scaffold.dart';
import 'package:authentication/widgets/custom_app_bar.dart';
import 'package:authentication/widgets/glass_inputs.dart';
import 'package:authentication/widgets/glass_surface.dart';
import 'package:authentication/widgets/token_list_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// 令牌列表主页面，展示所有已保存的身份验证令牌。
class TokenListScreen extends HookConsumerWidget {
  /// 创建令牌列表主页面。
  const TokenListScreen({
    super.key,
    this.searchQuery,
    this.initialCategory = -1,
  });
  final String? searchQuery;
  final int initialCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = searchQuery ?? '';
    final categoryFilter = useState(initialCategory);
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
        showAppToast(context, l10n.saveFailed);
      }
    });

    return AppScaffold(
      largeTitle: true,
      appBar: CustomAppBar(
        title: searchQuery == null ? l10n.accountsTab : l10n.searchResults,
        leftIcon: searchQuery == null ? null : Icons.arrow_back,
        leftOnPressed: (context) => Navigator.pop(context),
        rightIcon: Icons.add,
        rightTooltip: l10n.add,
        rightOnPressed: (_) => Navigator.pushNamed(context, AppRoutes.add),
      ),
      body: AppPageScrollView(
        maxWidth: 1400,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                if (autoBackupFailed)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: GlassContainer.card(
                      surfaceStyle: GlassSurfaceStyle.solid,
                      color: Theme.of(context).colorScheme.errorContainer,
                      child: GlassListTile(
                        title: Text(
                          autoBackupStatus ==
                                  AutomaticBackupStatus.configurationFailed
                              ? l10n.autoBackupConfigFailed
                              : l10n.autoBackupFailed,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.pushNamed(
                          context,
                          AppRoutes.automaticBackup,
                        ),
                      ),
                    ),
                  ),
                if (backupReminders && backupNeeded)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: AppGlassCard(
                      padding: EdgeInsets.zero,
                      child: GlassListTile(
                        title: Text(l10n.backupReminderMessage),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () =>
                            Navigator.pushNamed(context, AppRoutes.exportFile),
                      ),
                    ),
                  ),
                if (searchQuery?.isNotEmpty ?? false) ...[
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: GlassChip(
                      label: searchQuery!,
                      surfaceStyle: GlassSurfaceStyle.solid,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        l10n.allCategories,
                        style: Theme.of(context).textTheme.labelLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    AppMenuButton<int>(
                      tooltip: l10n.categoryFilter,
                      icon: selectedCategory == -1
                          ? Icons.filter_list
                          : Icons.filter_alt,
                      value: selectedCategory,
                      onSelected: (value) => categoryFilter.value = value,
                      options: {
                        -1: l10n.allCategories,
                        0: l10n.uncategorized,
                        for (final category in categoryList)
                          category.id: category.name,
                      },
                    ),
                    const SizedBox(width: 8),
                    AppMenuButton<int>(
                      tooltip: l10n.sortAccounts,
                      icon: Icons.sort,
                      value: sortMode,
                      onSelected: busy
                          ? null
                          : (value) => ref
                                .read(settingsOperationsProvider.notifier)
                                .updateInteger(sortModeKey, value),
                      options: {
                        0: l10n.sortCustom,
                        1: l10n.sortNameAscending,
                        2: l10n.sortNameDescending,
                        3: l10n.sortCopiesAscending,
                        4: l10n.sortCopiesDescending,
                      },
                    ),
                    if (sortMode == 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: AppBarIconButton(
                          tooltip: sortLocked
                              ? l10n.unlockSorting
                              : l10n.lockSorting,
                          icon: sortLocked
                              ? Icons.lock_outline
                              : Icons.lock_open,
                          onPressed: busy
                              ? null
                              : () => ref
                                    .read(settingsOperationsProvider.notifier)
                                    .update(sortLockedKey, !sortLocked),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (selectedCategory != -1)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: GlassChip(
                      surfaceStyle: GlassSurfaceStyle.solid,
                      label: selectedCategory == 0
                          ? l10n.uncategorized
                          : categoryList
                                .firstWhere((c) => c.id == selectedCategory)
                                .name,
                      onDeleted: () => categoryFilter.value = -1,
                    ),
                  ),
                if (sortMode == 0 &&
                    !sortLocked &&
                    (query.trim().isNotEmpty || selectedCategory != -1))
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      selectedCategory == -1
                          ? l10n.clearSearchToReorder
                          : l10n.clearFilterToReorder,
                    ),
                  ),
              ],
            ),
          ),
          authListAsync.when(
            data: (data) {
              if (categories.hasError || memberships.hasError) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(l10n.categoryLoadFailed)),
                );
              }
              if (categories.isLoading || memberships.isLoading) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: GlassProgressIndicator.circular()),
                );
              }
              if (data.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(l10n.noData)),
                );
              }
              final search = query.trim().toLowerCase();
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
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(l10n.noSearchResults)),
                );
              }
              if (sortMode == 0 &&
                  !sortLocked &&
                  search.isEmpty &&
                  selectedCategory == -1) {
                return SliverReorderableList(
                  itemCount: filtered.length,
                  onReorderItem: (oldIndex, newIndex) async {
                    if (busy) return;
                    final ids = filtered.map((e) => e.id).toList();
                    ids.insert(newIndex, ids.removeAt(oldIndex));
                    try {
                      await ref
                          .read(accountOperationsProvider.notifier)
                          .reorder(ids);
                    } catch (_) {
                      if (context.mounted) {
                        showAppToast(context, l10n.reorderFailed);
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
              return SliverGrid.builder(
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
            loading: () => const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: GlassProgressIndicator.circular()),
            ),
            error: (_, _) => SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.accountLoadFailed),
                    const SizedBox(height: 16),
                    AppButton(
                      onPressed: () => ref.invalidate(authEntryListProvider),
                      child: Text(l10n.screenProtectionRetry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
