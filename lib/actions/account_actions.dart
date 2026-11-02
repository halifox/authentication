import 'package:authentication/storage/database.dart';

import 'dart:async';

import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/validation.dart';

/// 令牌操作的结果状态
sealed class TokenFormResult {}

class TokenFormSuccess extends TokenFormResult {
  final bool isUpdate;
  TokenFormSuccess({required this.isUpdate});
}

class TokenFormConflict extends TokenFormResult {
  final OtpAccount pending;
  TokenFormConflict(this.pending);
}

class TokenFormError extends TokenFormResult {
  final AuthErrorCode code;
  final String? message;
  TokenFormError(this.code, {this.message});
}

/// 令牌表单页面的控制器，处理认证令牌的创建和更新。
Future<TokenFormResult> saveAccount(
  AppDatabase repo, {
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
    final companion = OtpAccount(
      id: id ?? 0,
      type: type,
      issuer: issuer,
      account: account,
      secret: type.toLowerCase() == 'motp'
          ? secret
          : secret.replaceAll(RegExp(r'\s+'), '').toUpperCase(),
      algorithm: algorithm,
      digits: digits,
      period: period,
      counter: counter,
      pin: pin,
      icon: icon,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    companion.validate();

    if (id == null) {
      if (!forceUpdate) {
        final existing = await repo.getConfigByAccountAndIssuer(
          companion.account,
          companion.issuer,
        );
        if (existing != null) {
          return TokenFormConflict(companion);
        }
      }

      if (forceUpdate) {
        final existing = await repo.getConfigByAccountAndIssuer(
          companion.account,
          companion.issuer,
        );
        if (existing != null) {
          await repo.updateConfig(
            companion.copyWith(
              id: existing.id,
              sortOrder: existing.sortOrder,
              createdAt: existing.createdAt,
            ),
          );
          return TokenFormSuccess(isUpdate: true);
        }
      }

      await repo.addConfig(companion);
      return TokenFormSuccess(isUpdate: false);
    } else {
      final current = await repo.watchConfig(id).first;
      if (current != null) {
        await repo.updateConfig(
          companion.copyWith(
            id: current.id,
            sortOrder: current.sortOrder,
            createdAt: current.createdAt,
          ),
        );
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
