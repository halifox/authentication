import 'dart:async';

import 'package:authentication/otp/account.dart';
import 'package:authentication/storage/database.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 单个令牌项的控制器，管理其 UI 状态和操作。
class TokenItem extends Notifier<TokenItemState> {
  TokenItem(this.id);
  final int id;
  Timer? _hideTimer;
  @override
  TokenItemState build() {
    ref.onDispose(() => _hideTimer?.cancel());
    return TokenItemState(id: id);
  }

  /// 切换令牌代码的可见性。
  void toggleReveal(int hideAfterSeconds) {
    _hideTimer?.cancel();
    final reveal = !state.isRevealed;
    state = state.copyWith(isRevealed: reveal);
    if (reveal && hideAfterSeconds > 0) {
      _hideTimer = Timer(Duration(seconds: hideAfterSeconds), () {
        state = state.copyWith(isRevealed: false);
      });
    }
  }

  /// 增加 HOTP 令牌的计数器。
  Future<void> incrementHotp(OtpAccount config) async {
    if (state.isUpdating) return;

    state = state.copyWith(isUpdating: true);
    try {
      await ref.read(appDatabaseProvider).advanceHotp(config.id);
    } finally {
      if (ref.mounted) state = state.copyWith(isUpdating: false);
    }
  }

  /// 删除当前令牌。
  Future<void> deleteToken() async {
    final repo = ref.read(appDatabaseProvider);
    await repo.deleteConfig(state.id);
  }

  /// 将代码复制到剪贴板。
  Future<bool> copyCode({required bool advanceHotp}) async {
    if (state.isUpdating) return false;
    state = state.copyWith(isUpdating: true);
    try {
      final db = ref.read(appDatabaseProvider);
      final account = await db.getConfig(id);
      if (account == null) throw StateError('Account not found.');
      await Clipboard.setData(
        ClipboardData(text: account.generateCodeString()),
      );
      try {
        await db.recordCopy(account, advanceHotp: advanceHotp);
        return true;
      } catch (_) {
        return false;
      }
    } finally {
      if (ref.mounted) state = state.copyWith(isUpdating: false);
    }
  }

  Future<void> resetCopyCount() =>
      ref.read(appDatabaseProvider).resetCopyCount(id);
}

/// 表示列表中单个令牌项的状态。
class TokenItemState {
  TokenItemState({
    required this.id,
    this.isRevealed = false,
    this.isUpdating = false,
  });

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

final tokenItemProvider = NotifierProvider.autoDispose
    .family<TokenItem, TokenItemState, int>(TokenItem.new);
