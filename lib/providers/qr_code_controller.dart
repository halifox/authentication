import 'dart:io';

import 'package:auth/db/auth_entries_ext.dart';
import 'package:auth/db/database.dart';
import 'package:auth/domain/models/auth_validation.dart';
import 'package:auth/providers/auth_repository_provider.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'qr_code_controller.g.dart';

sealed class QrProcessResult {}

class QrProcessSuccess extends QrProcessResult {
  final bool isUpdate;
  QrProcessSuccess({required this.isUpdate});
}

class QrProcessConflict extends QrProcessResult {
  final AuthEntriesCompanion pending;
  QrProcessConflict(this.pending);
}

class QrProcessError extends QrProcessResult {
  final AuthErrorCode code;
  final String? message;
  QrProcessError(this.code, {this.message});
}

/// 处理二维码扫描和图片上传功能的控制器。
@riverpod
class QrCodeController extends _$QrCodeController {
  @override
  void build() {}

  /// 处理扫描到的 URI 字符串。
  /// [forceUpdate] 用于在检测到冲突并确认后强制更新。
  Future<QrProcessResult> processCode(String uriString, {bool forceUpdate = false}) async {
    try {
      final AuthEntriesCompanion config = AuthEntryUtils.parse(uriString);
      // 验证配置
      config.validateThrow();

      final repo = ref.read(authRepositoryProvider);

      if (!forceUpdate) {
        final existing = await repo.getConfigByAccountAndIssuer(config.account.value, config.issuer.value);
        if (existing != null) {
          return QrProcessConflict(config);
        }
        await repo.addConfig(config);
        return QrProcessSuccess(isUpdate: false);
      } else {
        final existing = await repo.getConfigByAccountAndIssuer(config.account.value, config.issuer.value);
        if (existing != null) {
          await repo.updateConfig(existing.copyWithCompanion(config));
          return QrProcessSuccess(isUpdate: true);
        } else {
          // 这种情况很少见（并发删除？），降级为添加
          await repo.addConfig(config);
          return QrProcessSuccess(isUpdate: false);
        }
      }
    } on AuthFailure catch (e) {
       return QrProcessError(e.code, message: e.message);
    } catch (e) {
       return QrProcessError(AuthErrorCode.unknown, message: e.toString());
    }
  }

  /// 分析图片文件中的二维码（仅逻辑，文件选择由 UI 传入）。
  Future<List<String>> analyzeFile(String path) async {
    final controller = MobileScannerController();
    try {
      final BarcodeCapture? barcodeCapture = await controller.analyzeImage(path);
      if (barcodeCapture != null && barcodeCapture.barcodes.isNotEmpty) {
        return barcodeCapture.barcodes.map((e) => e.rawValue).whereType<String>().toList();
      }
      return [];
    } finally {
      controller.dispose();
    }
  }
  
  /// 检查平台支持 (Helper for UI)
  bool get isPlatformSupported => kIsWeb || Platform.isAndroid || Platform.isIOS;
  
  /// 选取文件 (Helper mostly for UI convenience, but depends on plugin not context)
  Future<XFile?> pickImage() async {
    return await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(extensions: ['jpg', 'jpeg', 'png']),
      ],
    );
  }
}
