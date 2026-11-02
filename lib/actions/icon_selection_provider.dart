import 'package:authentication/otp/account.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

String? matchBuiltInIcon(String issuer, Iterable<String> icons) {
  final value = issuer.trim().toLowerCase();
  if (value.isEmpty || !RegExp(r'^[a-z0-9 ._-]+$').hasMatch(value)) return null;
  final normalized = value.replaceAll(RegExp(r'[ ._-]'), '');
  if (normalized.isEmpty) return null;
  final matches = icons
      .where(
        (name) =>
            name.endsWith('.svg') &&
            name
                    .substring(0, name.length - 4)
                    .toLowerCase()
                    .replaceAll(RegExp(r'[ ._-]'), '') ==
                normalized,
      )
      .toList();
  return matches.length == 1 ? 'assets/icons/${matches.single}' : null;
}

OtpAccount suggestBuiltInIcon(OtpAccount account, Iterable<String> icons) {
  if (account.icon != 'assets/icons/passkey.svg') return account;
  final icon = matchBuiltInIcon(account.issuer, icons);
  return icon == null ? account : account.copyWith(icon: icon);
}

/// 管理用于过滤图标的当前搜索查询。
class IconSearchQuery extends Notifier<String> {
  @override
  String build() {
    return '';
  }

  /// 更新搜索查询状态。
  void update(String query) {
    state = query;
  }
}

/// 从资源清单异步加载所有可用的图标文件名。
Future<List<String>> allIcons(Ref ref) async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  return manifest
      .listAssets()
      .where(
        (String key) => key.startsWith('assets/icons/') && key.endsWith('.svg'),
      )
      .map((e) => e.split('/').last)
      .toList();
}

/// 根据当前搜索查询过滤所有图标的列表。
Future<List<String>> filteredIcons(Ref ref) async {
  final allIcons = await ref.watch(allIconsProvider.future);
  final query = ref.watch(iconSearchQueryProvider).toLowerCase();

  if (query.isEmpty) {
    return allIcons;
  }

  return allIcons.where((icon) => icon.toLowerCase().contains(query)).toList();
}

final iconSearchQueryProvider =
    NotifierProvider.autoDispose<IconSearchQuery, String>(IconSearchQuery.new);
final allIconsProvider = FutureProvider.autoDispose<List<String>>(allIcons);
final filteredIconsProvider = FutureProvider.autoDispose<List<String>>(
  filteredIcons,
);
