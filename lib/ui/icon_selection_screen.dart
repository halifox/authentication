import 'package:auth/l10n/generated/app_localizations.dart';
import 'package:auth/providers/icon_selection_provider.dart';
import 'package:auth/ui/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';

/// 图标选择页面，允许用户搜索并为账号选择一个合适的服务图标。
class IconSelectionScreen extends ConsumerWidget {
  /// 创建图标选择页面。
  const IconSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredIconsAsync = ref.watch(filteredIconsProvider);

    return Scaffold(
      appBar: CustomAppBar(title: AppLocalizations.of(context)!.selectIcon),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              onChanged: (String value) => ref.read(iconSearchQueryProvider.notifier).update(value),
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(14.0))),
                prefixIcon: const Icon(Icons.search),
                hintText: AppLocalizations.of(context)!.search,
              ),
            ),
          ),
          Expanded(
            child: filteredIconsAsync.when(
              data: (icons) => Scrollbar(
                interactive: true,
                thumbVisibility: true,
                thickness: 8,
                radius: const Radius.circular(12),
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 60, crossAxisSpacing: 16, mainAxisSpacing: 16),
                  itemCount: icons.length,
                  itemBuilder: (BuildContext context, int index) {
                    final icon = icons[index];
                    final fullPath = 'assets/icons/$icon';
                    return GestureDetector(
                      onTap: () => Navigator.pop(context, fullPath),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(14)),
                        child: SvgPicture.asset(fullPath, width: 28, height: 28, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.onPrimary, BlendMode.srcIn)),
                      ),
                    );
                  },
                ),
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}