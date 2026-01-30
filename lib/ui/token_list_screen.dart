import 'dart:io';

import 'package:auth/l10n/generated/app_localizations.dart';
import 'package:auth/providers/auth_repository_provider.dart';
import 'package:auth/providers/token_list_controller.dart';
import 'package:auth/ui/token_list_item.dart';
import 'package:auth/ui/custom_app_bar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 令牌列表主页面，展示所有已保存的身份验证令牌。
class TokenListScreen extends ConsumerWidget {
  /// 创建令牌列表主页面。
  const TokenListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 监听列表 Provider。每当数据库发生变化时，此流都会更新。
    final authListAsync = ref.watch(authEntryListProvider);
    final controller = ref.watch(tokenListControllerProvider.notifier);

    Widget scaffold = Scaffold(
      appBar: CustomAppBar(
        title: AppLocalizations.of(context)!.appTitle,
        leftIcon: Icons.settings,
        leftOnPressed: (_) => controller.navigateToSettings(),
        rightIcon: Icons.add,
        rightOnPressed: (_) => controller.navigateToAddAccount(),
      ),
      body: authListAsync.when(
        data: (data) {
          if (data.isEmpty) {
            return Center(child: Text(AppLocalizations.of(context)!.noData));
          }
          return GridView.builder(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 700,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: 140,
            ),
            itemCount: data.length,
            itemBuilder: (BuildContext context, int index) {
              final config = data[index];
              // 当列表顺序改变或更新发生时，Key 对于维护 TokenListItem 中定时器的状态至关重要。
              return TokenListItem(key: ValueKey(config.id), config: config);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );

    if (!kIsWeb && Platform.isAndroid) {
      scaffold = AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          systemNavigationBarColor: Theme.of(context).colorScheme.surface,
          systemNavigationBarDividerColor: Theme.of(context).colorScheme.surface,
          systemNavigationBarIconBrightness: Theme.of(context).colorScheme.brightness,
          statusBarColor: Colors.transparent,
          statusBarBrightness: Theme.of(context).colorScheme.brightness,
          statusBarIconBrightness:
              (Theme.of(context).colorScheme.brightness == Brightness.dark) ? Brightness.light : Brightness.dark,
        ),
        child: scaffold,
      );
    }

    return scaffold;
  }
}
