import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/screens/add_account_screen.dart';
import 'package:authentication/screens/settings_screen.dart';
import 'package:authentication/screens/token_list_screen.dart';
import 'package:authentication/widgets/glass_quality.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

/// Primary destinations retain their own scroll position and local form state.
class MainNavigationScreen extends HookWidget {
  const MainNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final selected = useState(0);
    final visited = useState({0});
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final keyboardVisible = MediaQuery.viewInsetsOf(context).bottom > 0;
    void select(int index) {
      FocusManager.instance.primaryFocus?.unfocus();
      visited.value = {...visited.value, index};
      selected.value = index;
    }

    return PopScope(
      canPop: selected.value == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) select(0);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: keyboardVisible ? 0 : 88),
              child: IndexedStack(
                index: selected.value,
                children: [
                  TickerMode(
                    enabled: selected.value == 0,
                    child: const TokenListScreen(),
                  ),
                  TickerMode(
                    enabled: selected.value == 1,
                    child: visited.value.contains(1)
                        ? const AddAccountScreen(
                            page: AccountActionPage.backupHub,
                            root: true,
                          )
                        : const SizedBox.shrink(),
                  ),
                  TickerMode(
                    enabled: selected.value == 2,
                    child: visited.value.contains(2)
                        ? const SettingsScreen(root: true)
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
            if (!keyboardVisible)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SafeArea(
                  top: false,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 620),
                      child: GlassTabBar.bottom(
                        selectedIndex: selected.value,
                        onTabSelected: select,
                        quality: appGlassQuality,
                        backgroundQuality: appGlassQuality,
                        barHeight: 62,
                        verticalPadding: 12,
                        horizontalPadding: 18,
                        indicatorColor: colors.primary.withValues(alpha: .16),
                        interactionGlowColor: colors.primary,
                        selectedIconColor: colors.primary,
                        unselectedIconColor: colors.onSurfaceVariant,
                        selectedLabelColor: colors.primary,
                        unselectedLabelColor: colors.onSurfaceVariant,
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
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
