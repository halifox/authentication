import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'icon_selection_provider.g.dart';

/// 管理用于过滤图标的当前搜索查询。
@riverpod
class IconSearchQuery extends _$IconSearchQuery {
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
@riverpod
Future<List<String>> allIcons(Ref ref) async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  return manifest.listAssets()
      .where((String key) => key.startsWith('assets/icons/') && key.endsWith('.svg'))
      .map((e) => e.split('/').last)
      .toList();
}

/// 根据当前搜索查询过滤所有图标的列表。
@riverpod
Future<List<String>> filteredIcons(Ref ref) async {
  final allIcons = await ref.watch(allIconsProvider.future);
  final query = ref.watch(iconSearchQueryProvider).toLowerCase();

  if (query.isEmpty) {
    return allIcons;
  }

  return allIcons.where((icon) => icon.toLowerCase().contains(query)).toList();
}