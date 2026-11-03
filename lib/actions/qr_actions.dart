import 'dart:io';

import 'package:authentication/actions/icon_selection_provider.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/validation.dart';
import 'package:authentication/storage/database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

sealed class QrProcessResult {}

class QrProcessSuccess extends QrProcessResult {
  final bool isUpdate;
  QrProcessSuccess({required this.isUpdate});
}

class QrProcessConflict extends QrProcessResult {
  final OtpAccount pending;
  QrProcessConflict(this.pending);
}

class QrProcessError extends QrProcessResult {
  final AuthErrorCode code;
  final String? message;
  QrProcessError(this.code, {this.message});
}

/// 处理二维码扫描和图片上传功能的控制器。
Future<QrProcessResult> processQrCode(
  AppDatabase repo,
  String uriString, {
  bool forceUpdate = false,
  Iterable<String> icons = const [],
}) async {
  try {
    final config = suggestBuiltInIcon(
      parseOtpUri(
        uriString,
        detectSteam: true,
      ).copyWith(createdAt: DateTime.now().millisecondsSinceEpoch),
      icons,
    );
    // 验证配置
    config.validate();

    if (!forceUpdate) {
      final existing = await repo.getConfigByAccountAndIssuer(
        config.account,
        config.issuer,
      );
      if (existing != null) {
        return QrProcessConflict(config);
      }
      await repo.addConfig(config);
      return QrProcessSuccess(isUpdate: false);
    } else {
      final existing = await repo.getConfigByAccountAndIssuer(
        config.account,
        config.issuer,
      );
      if (existing != null) {
        await repo.updateConfig(
          config.copyWith(
            id: existing.id,
            icon: existing.icon,
            sortOrder: existing.sortOrder,
            createdAt: existing.createdAt,
            copyCount: existing.copyCount,
          ),
        );
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
Future<List<String>> analyzeQrFile(String path) async {
  final controller = MobileScannerController();
  try {
    final BarcodeCapture? barcodeCapture = await controller.analyzeImage(path);
    if (barcodeCapture != null && barcodeCapture.barcodes.isNotEmpty) {
      return barcodeCapture.barcodes
          .map((e) => e.rawValue)
          .whereType<String>()
          .toList();
    }
    return [];
  } finally {
    controller.dispose();
  }
}

/// 检查平台支持 (Helper for UI)
bool get isQrPlatformSupported =>
    kIsWeb || Platform.isAndroid || Platform.isIOS;

/// 选取文件 (Helper mostly for UI convenience, but depends on plugin not context)
Future<PlatformFile?> pickQrImage() =>
    FilePicker.pickFile(type: FileType.image);
