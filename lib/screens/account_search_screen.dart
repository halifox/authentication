import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/category_provider.dart';
import 'package:authentication/otp/otp_provider.dart';
import 'package:authentication/otp/search_provider.dart';
import 'package:authentication/widgets/app_scaffold.dart';
import 'package:authentication/widgets/custom_app_bar.dart';
import 'package:authentication/widgets/glass_inputs.dart';
import 'package:authentication/widgets/glass_surface.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class AccountSearchScreen extends ConsumerWidget {
  const AccountSearchScreen({
    required this.showHistory,
    required this.draft,
    required this.onDismiss,
    required this.onQuerySelected,
    required this.onCategorySelected,
    super.key,
  });

  final bool showHistory;
  final String draft;
  final VoidCallback onDismiss;
  final ValueChanged<String> onQuerySelected;
  final ValueChanged<int> onCategorySelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final history = ref.watch(recentSearchesProvider);
    final categories = ref.watch(categoriesProvider);
    final accounts = ref.watch(authEntryListProvider);
    final memberships = ref.watch(categoryMembershipsProvider);
    final busy = ref.watch(searchHistoryOperationsProvider).isLoading;
    final colors = Theme.of(context).colorScheme;

    Widget empty(String message) => SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search, size: 48, color: colors.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(
              l10n.searchHistoryHint,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );

    Widget error(String message, VoidCallback retry) => SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton(
              onPressed: retry,
              child: Text(l10n.screenProtectionRetry),
            ),
            if (showHistory)
              AppButton(
                prominent: false,
                onPressed: busy
                    ? null
                    : () => ref
                          .read(searchHistoryOperationsProvider.notifier)
                          .clear(),
                child: Text(l10n.clearSearchHistory),
              ),
          ],
        ),
      ),
    );

    Future<void> clearHistory() async {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AppDialog(
          title: l10n.clearSearchHistory,
          content: Text(l10n.clearSearchHistoryConfirm),
          actions: [
            GlassDialogAction(
              label: l10n.cancel,
              onPressed: () => Navigator.pop(dialogContext, false),
            ),
            GlassDialogAction(
              label: l10n.clearSearchHistory,
              isDestructive: true,
              onPressed: () => Navigator.pop(dialogContext, true),
            ),
          ],
        ),
      );
      if (confirmed == true && context.mounted) {
        await ref.read(searchHistoryOperationsProvider.notifier).clear();
      }
    }

    return AppScaffold(
      largeTitle: true,
      appBar: CustomAppBar(
        title: l10n.search,
        leftIcon: Icons.close,
        leftTooltip: l10n.cancel,
        leftOnPressed: (_) => onDismiss(),
        rightIcon: showHistory && (history.value?.isNotEmpty ?? false)
            ? Icons.delete_sweep_outlined
            : null,
        rightTooltip: l10n.clearSearchHistory,
        rightOnPressed: busy ? null : (_) => clearHistory(),
      ),
      body: AppPageScrollView(
        slivers: [
          if (showHistory)
            history.when(
              loading: () => const SliverFillRemaining(
                child: Center(child: GlassProgressIndicator.circular()),
              ),
              error: (_, _) => error(
                l10n.searchHistoryLoadFailed,
                () => ref.invalidate(recentSearchesProvider),
              ),
              data: (queries) {
                final filtered = queries
                    .where(
                      (query) => query.toLowerCase().contains(
                        draft.trim().toLowerCase(),
                      ),
                    )
                    .toList();
                if (filtered.isEmpty) return empty(l10n.recentSearchesEmpty);
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: AppGlassGroup(
                        header: Text(l10n.recentSearches),
                        children: [
                          for (final query in filtered)
                            GlassListTile(
                              leading: const Icon(Icons.history),
                              title: Text(
                                query,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              titleStyle: Theme.of(context).textTheme.bodyLarge,
                              onTap: busy ? null : () => onQuerySelected(query),
                              trailing: AppBarIconButton(
                                icon: Icons.close,
                                tooltip: l10n.delete,
                                onPressed: busy
                                    ? null
                                    : () => ref
                                          .read(
                                            searchHistoryOperationsProvider
                                                .notifier,
                                          )
                                          .remove(query),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          else if (categories.hasError ||
              accounts.hasError ||
              memberships.hasError)
            error(l10n.categoryLoadFailed, () {
              ref.invalidate(categoriesProvider);
              ref.invalidate(authEntryListProvider);
              ref.invalidate(categoryMembershipsProvider);
            })
          else if (categories.isLoading ||
              accounts.isLoading ||
              memberships.isLoading)
            const SliverFillRemaining(
              child: Center(child: GlassProgressIndicator.circular()),
            )
          else ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Text(
                  l10n.searchHistoryHint,
                  style: Theme.of(context).textTheme.bodyLarge
                      ?.copyWith(color: colors.onSurfaceVariant),
                ),
              ),
            ),
            SliverGrid.builder(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent:
                    MediaQuery.textScalerOf(context).scale(1) > 1.3 ? 760 : 260,
                mainAxisExtent:
                    108 +
                    (MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0) -
                            1) *
                        70,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: categories.value!.length + 2,
              itemBuilder: (context, index) {
                final id = index == 0
                    ? -1
                    : index == 1
                    ? 0
                    : categories.value![index - 2].id;
                final title = index == 0
                    ? l10n.allCategories
                    : index == 1
                    ? l10n.uncategorized
                    : categories.value![index - 2].name;
                final count = accounts.value!.where((account) {
                  final assigned = memberships.value![account.id] ?? <int>{};
                  return id == -1 ||
                      (id == 0 ? assigned.isEmpty : assigned.contains(id));
                }).length;
                return AppGlassCard(
                  padding: EdgeInsets.zero,
                  child: GlassListTile(
                    title: Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    titleStyle: Theme.of(context).textTheme.titleMedium,
                    subtitle: Text(l10n.searchAccountCount(count)),
                    subtitleStyle: Theme.of(context).textTheme.bodySmall
                        ?.copyWith(color: colors.onSurfaceVariant),
                    onTap: () => onCategorySelected(id),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
