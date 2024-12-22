import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:purity_auth/auth.dart';
import 'package:purity_auth/auth_repository.dart';

/// 提示用户选择图像文件（jpg, jpeg, png），
/// 然后扫描和处理图像中的二维码内容。
///
/// 如果未选择任何文件，函数将直接返回。
///
Future<void> selectAndProcessQRCode() async {
  const XTypeGroup imageTypes = XTypeGroup(extensions: ['jpg', 'jpeg', 'png']);
  XFile? selectedFile = await openFile(acceptedTypeGroups: [imageTypes]);

  if (selectedFile == null) {
    // TODO: 用户未选择文件
    return;
  }
  await scanAndProcessQRCode(selectedFile.path);
}

/// 根据文件路径扫描图像中的二维码并进行处理。
///
/// [filePath] 图像文件的路径。
/// 如果扫描成功，将处理扫描结果；如果失败或发生错误，将显示错误提示。
///
Future<void> scanAndProcessQRCode(String filePath) async {
  final inputImage = InputImage.fromFilePath(filePath);
  final barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);
  final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);
  await handleQRCode(barcodes);
}

/// 处理二维码内容，解析并存储有效的认证信息。
///
/// - 如果未识别到二维码，显示提示对话框。
/// - 如果识别到多个二维码，显示提示对话框。
/// - 如果二维码内容无效或解析失败，显示相应错误提示。
///
/// [barcodes] 识别到的二维码列表。
Future<int?> handleQRCode(List<Barcode>? barcodes) async {
  if (barcodes == null || barcodes.isEmpty) {
    return showAlert("扫描结果", "未识别到二维码");
  }
  if (barcodes.length > 1) {
    return showAlert("扫描结果", "识别到多个二维码");
  }

  try {
    final Barcode barcode = barcodes.first;
    final String rawValue = barcode.rawValue ?? "";
    final AuthConfiguration configuration = AuthConfiguration.parse(rawValue);
    await Get.find<AuthRepository>().upsert(configuration);
    return 0;
  } on ArgumentError catch (e) {
    return showAlert("参数错误", e.message);
  } on FormatException catch (e) {
    return showAlert("格式错误", e.message);
  } catch (e) {
    return showAlert("未知错误", e.toString());
  }
}

/// 显示一个信息对话框，提示用户确认消息。
///
/// [title] 对话框的标题。
/// [message] 对话框的消息内容。
Future<int?> showAlert(
  String title,
  String message, {
  int? result,
}) {
  return Get.generalDialog<int>(
    pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Get.back(result: result),
            child: Text("确定"),
          ),
        ],
      );
    },
  );
}
