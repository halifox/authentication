import 'dart:io';

import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/otp/otp_provider.dart';
import 'package:authentication/router/app_router.dart';
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
    final l10n = AppLocalizations.of(context)!;

    // 监听列表 Provider。每当数据库发生变化时，此流都会更新。
    final authListAsync = ref.watch(authEntryListProvider);

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
          Expanded(
            child: authListAsync.when(
              data: (data) {
                if (data.isEmpty) {
                  return Center(child: Text(l10n.noData));
                }
                final search = query.value.trim().toLowerCase();
                final filtered = data
                    .where(
                      (entry) =>
                          entry.issuer.toLowerCase().contains(search) ||
                          entry.account.toLowerCase().contains(search),
                    )
                    .toList();
                if (filtered.isEmpty) {
                  return Center(child: Text(l10n.noSearchResults));
                }
                return GridView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 700,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 140,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final config = filtered[index];
                    return TokenListItem(
                      key: ValueKey(config.id),
                      config: config,
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
