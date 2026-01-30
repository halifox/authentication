import 'dart:async';

import 'package:auth/db/auth_entries_ext.dart';
import 'package:auth/db/database.dart';
import 'package:auth/domain/models/auth_validation.dart';
import 'package:auth/providers/auth_repository_provider.dart';
import 'package:drift/drift.dart' as drift;
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_form_controller.g.dart';

/// 令牌操作的结果状态
sealed class TokenFormResult {}

class TokenFormSuccess extends TokenFormResult {
  final bool isUpdate;
  TokenFormSuccess({required this.isUpdate});
}

class TokenFormConflict extends TokenFormResult {
  final AuthEntriesCompanion pending;
  TokenFormConflict(this.pending);
}

class TokenFormError extends TokenFormResult {
  final AuthErrorCode code;
  final String? message;
  TokenFormError(this.code, {this.message});
}

/// 令牌表单页面的控制器，处理认证令牌的创建和更新。
@riverpod
class TokenFormController extends _$TokenFormController {
  @override
  void build() {}

  /// 根据提供的表单数据保存新令牌或更新现有令牌。
  /// 返回操作结果，由 UI 决定后续动作（如导航或弹窗）。
  Future<TokenFormResult> onSave({
    required int? id,
    required String type,
    required String issuer,
    required String account,
    required String secret,
    required String algorithm,
    required int digits,
    required int period,
    required int counter,
    required String pin,
    required String icon,
    bool forceUpdate = false, // 用于在冲突确认后强制更新
  }) async {
    try {
      final companion = AuthEntriesCompanion(
        id: id != null ? drift.Value(id) : const drift.Value.absent(),
        type: drift.Value(type),
        issuer: drift.Value(issuer),
        account: drift.Value(account),
        secret: drift.Value(secret),
        algorithm: drift.Value(algorithm),
        digits: drift.Value(digits),
        period: drift.Value(period),
        counter: drift.Value(counter),
        pin: drift.Value(pin),
        icon: drift.Value(icon),
        scheme: const drift.Value('otpauth'),
        sortOrder: const drift.Value(0),
        createdAt: id == null ? drift.Value(DateTime.now().millisecondsSinceEpoch) : const drift.Value.absent(),
      );

      // 验证逻辑
      companion.validateThrow();

      final repo = ref.read(authRepositoryProvider);

      if (id == null) {
        if (!forceUpdate) {
          final existing = await repo.getConfigByAccountAndIssuer(companion.account.value, companion.issuer.value);
          if (existing != null) {
            return TokenFormConflict(companion);
          }
        }
        
        if (forceUpdate) {
          final existing = await repo.getConfigByAccountAndIssuer(companion.account.value, companion.issuer.value);
          if (existing != null) {
            await repo.updateConfig(existing.copyWithCompanion(companion));
            return TokenFormSuccess(isUpdate: true);
          }
        }
        
        await repo.addConfig(companion);
        return TokenFormSuccess(isUpdate: false);
      } else {
        final current = await repo.watchConfig(id).first;
        if (current != null) {
          await repo.updateConfig(current.copyWithCompanion(companion));
          return TokenFormSuccess(isUpdate: true);
        }
        return TokenFormError(AuthErrorCode.unknown, message: 'ID not found');
      }
    } on AuthFailure catch (e) {
      return TokenFormError(e.code, message: e.message);
    } catch (e) {
      return TokenFormError(AuthErrorCode.unknown, message: e.toString());
    }
  }
}