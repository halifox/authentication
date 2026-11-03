import 'dart:io';

import 'package:authentication/actions/icon_selection_provider.dart';
import 'package:authentication/otp/account.dart';
import 'package:authentication/otp/validation.dart';
import 'package:authentication/storage/database.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as image;
import 'package:zxing2/qrcode.dart';

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
  QrProcessError(this.code);
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
    return QrProcessError(e.code);
  } catch (_) {
    return QrProcessError(AuthErrorCode.unknown);
  }
}

const maxQrImageBytes = 10 * 1024 * 1024;

/// Decode a single QR code without sending the image to a network service.
String decodeQrImage(Uint8List bytes) {
  if (bytes.isEmpty || bytes.length > maxQrImageBytes) {
    throw const FormatException('Invalid image size.');
  }
  try {
    final decoder = image.findDecoderForData(bytes);
    final info = decoder?.startDecode(bytes);
    if (info == null ||
        info.width < 1 ||
        info.height < 1 ||
        info.width > 4096 ||
        info.height > 4096 ||
        info.width * info.height > 16000000 ||
        info.numFrames != 1) {
      throw const FormatException();
    }
    final decoded = decoder!.decodeFrame(0);
    if (decoded == null) throw const FormatException();
    final background = image.Image(
      width: decoded.width,
      height: decoded.height,
    );
    image.fill(background, color: image.ColorRgb8(255, 255, 255));
    image.compositeImage(background, decoded);
    final rgba = background
        .convert(numChannels: 4)
        .getBytes(order: image.ChannelOrder.abgr);
    final source = RGBLuminanceSource(
      decoded.width,
      decoded.height,
      rgba.buffer.asInt32List(),
    );
    return QRCodeReader().decode(BinaryBitmap(HybridBinarizer(source))).text;
  } catch (_) {
    throw const FormatException('Invalid or unsupported QR image.');
  }
}

/// 检查平台支持 (Helper for UI)
bool get isQrPlatformSupported =>
    kIsWeb || Platform.isAndroid || Platform.isIOS;

/// 选取文件 (Helper mostly for UI convenience, but depends on plugin not context)
Future<PlatformFile?> pickQrImage() =>
    FilePicker.pickFile(type: FileType.image);
