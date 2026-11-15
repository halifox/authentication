import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/search_provider.dart';
import 'package:authentication/router/app_router.dart';
import 'package:authentication/screens/account_search_screen.dart';
import 'package:authentication/screens/add_account_screen.dart';
import 'package:authentication/screens/settings_screen.dart';
import 'package:authentication/screens/token_list_screen.dart';
import 'package:authentication/widgets/glass_inputs.dart';
import 'package:authentication/widgets/glass_quality.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

class MainNavigationScreen extends HookConsumerWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = useState(0);
    final visited = useState({0});
    final searching = useState(false);
    final historyFocused = useState(false);
    final searchVisited = useState(false);
    final controller = useTextEditingController();
    final focus = useFocusNode();
    useListenable(controller);
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final busy = ref.watch(searchHistoryOperationsProvider).isLoading;
    ref.listen(searchHistoryOperationsProvider, (_, next) {
      if (next.hasError && context.mounted) {
        showAppToast(context, l10n.searchHistoryFailed);
      }
    });

    void dismissSearch() {
      focus.unfocus();
      searching.value = false;
      historyFocused.value = false;
      controller.clear();
    }

    void select(int index) {
      dismissSearch();
      visited.value = {...visited.value, index};
      selected.value = index;
    }

    Future<void> results(String text, [int? categoryId]) async {
      final query = text.trim();
      if (busy || (query.isEmpty && categoryId == null)) return;
      if (query.isNotEmpty) {
        final saved = await ref
            .read(searchHistoryOperationsProvider.notifier)
            .remember(query);
        if (!context.mounted || !saved) return;
      }
      focus.unfocus();
      controller.clear();
      historyFocused.value = true;
      await Navigator.pushNamed(
        context,
        AppRoutes.searchResults,
        arguments: (query: query, categoryId: categoryId ?? -1),
      );
    }

    return PopScope(
      canPop: selected.value == 0 && !searching.value,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          if (searching.value) {
            dismissSearch();
          } else {
            select(0);
          }
        }
      },
      child: CupertinoTheme(
        data: CupertinoThemeData(
          brightness: colors.brightness,
          primaryColor: colors.primary,
          scaffoldBackgroundColor: colors.surface,
        ),
        child: GlassScaffold(
          backgroundColor: colors.surface,
          statusBarStyle: GlassStatusBarStyle.auto,
          extendBody: false,
          bottomBar: GlassTabBar.searchable(
            selectedIndex: selected.value,
            onTabSelected: select,
            isSearchActive: searching.value,
            quality: appGlassQuality,
            backgroundQuality: appGlassQuality,
            barHeight:
                62 +
                (MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0) -
                        1) *
                    16,
            searchBarHeight:
                52 +
                (MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0) -
                        1) *
                    16,
            verticalPadding: 12,
            horizontalPadding: 18,
            indicatorColor: colors.primary.withValues(alpha: .16),
            interactionGlowColor: colors.primary,
            selectedIconColor: colors.primary,
            unselectedIconColor: colors.onSurfaceVariant,
            selectedLabelColor: colors.primary,
            unselectedLabelColor: colors.onSurfaceVariant,
            searchConfig: GlassSearchBarConfig(
              controller: controller,
              focusNode: focus,
              hintText: l10n.searchAccounts,
              autoFocusOnExpand: false,
              autocorrect: false,
              enableSuggestions: false,
              showsCancelButton: true,
              textInputAction: TextInputAction.search,
              clearButtonSemanticLabel: l10n.clearSearch,
              cancelButtonSemanticLabel: l10n.cancel,
              trailingBuilder: (_) => const SizedBox.shrink(),
              onSubmitted: (value) => results(value),
              onSearchToggle: (active) {
                if (active) {
                  searchVisited.value = true;
                  searching.value = true;
                  historyFocused.value = false;
                } else {
                  dismissSearch();
                }
              },
              onSearchFocusChanged: (focused) {
                if (searching.value && focused) historyFocused.value = true;
              },
            ),
            tabs: [
              GlassTab(
                icon: const Icon(Icons.shield_outlined),
                activeIcon: const Icon(Icons.shield),
                label: l10n.accountsTab,
              ),
              GlassTab(
                icon: const Icon(Icons.backup_outlined),
                activeIcon: const Icon(Icons.backup),
                label: l10n.backupTab,
              ),
              GlassTab(
                icon: const Icon(Icons.settings),
                activeIcon: const Icon(Icons.settings),
                label: l10n.settings,
              ),
            ],
          ),
          body: IndexedStack(
            index: searching.value ? 3 : selected.value,
            children: [
              TickerMode(
                enabled: !searching.value && selected.value == 0,
                child: const TokenListScreen(),
              ),
              TickerMode(
                enabled: !searching.value && selected.value == 1,
                child: visited.value.contains(1)
                    ? const AddAccountScreen(
                        page: AccountActionPage.backupHub,
                        root: true,
                      )
                    : const SizedBox.shrink(),
              ),
              TickerMode(
                enabled: !searching.value && selected.value == 2,
                child: visited.value.contains(2)
                    ? const SettingsScreen(root: true)
                    : const SizedBox.shrink(),
              ),
              TickerMode(
                enabled: searching.value,
                child: searchVisited.value
                    ? AccountSearchScreen(
                        showHistory: historyFocused.value,
                        draft: controller.text,
                        onDismiss: dismissSearch,
                        onQuerySelected: (query) => results(query),
                        onCategorySelected: (category) => results('', category),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
