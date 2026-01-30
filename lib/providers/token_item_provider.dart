import 'package:auth/db/database.dart';
import 'package:auth/providers/auth_repository_provider.dart';
import 'package:auth/router/app_router.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_item_provider.g.dart';

/// 单个令牌项的控制器，管理其 UI 状态和操作。
@riverpod
class TokenItem extends _$TokenItem {
  @override
  TokenItemState build(int id) {
    return TokenItemState(id: id);
  }

  /// 切换令牌代码的可见性。
  void toggleReveal() {
    state = state.copyWith(isRevealed: !state.isRevealed);
  }

  /// 增加 HOTP 令牌的计数器。
  Future<void> incrementHotp(AuthEntry config) async {
    if (state.isUpdating) return;
    
    state = state.copyWith(isUpdating: true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final newCounter = config.counter + 1;
      await repo.updateConfig(config.copyWith(counter: newCounter));
    } finally {
      state = state.copyWith(isUpdating: false);
    }
  }

  /// 删除当前令牌。
  Future<void> deleteToken() async {
    final repo = ref.read(authRepositoryProvider);
    await repo.deleteConfig(state.id);
  }

  /// 跳转到编辑表单页面。
  void editToken(AuthEntry config) {
    ref.read(routerProvider).pushNamed(AppRoutes.formName, extra: config.copyWith());
  }

  /// 将代码复制到剪贴板。
  Future<void> copyCode(String code) async {
    await Clipboard.setData(ClipboardData(text: code));
  }
}

/// 表示列表中单个令牌项的状态。
class TokenItemState {
  TokenItemState({required this.id, this.isRevealed = false, this.isUpdating = false});

  final int id;
  /// 代码当前是否已显示（即未被遮挡）。
  final bool isRevealed;
  /// 是否正在进行更新操作（如 HOTP 增量）。
  final bool isUpdating;

  TokenItemState copyWith({bool? isRevealed, bool? isUpdating}) {
    return TokenItemState(
      id: id,
      isRevealed: isRevealed ?? this.isRevealed,
      isUpdating: isUpdating ?? this.isUpdating,
    );
  }
}