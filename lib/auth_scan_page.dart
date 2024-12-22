import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:purity_auth/camera_preview_widget.dart';
import 'package:purity_auth/image_tools.dart';
import 'package:purity_auth/top_bar.dart';

/// 扫描条形码的页面
class AuthScanPage extends StatefulWidget {
  @override
  _AuthScanPageState createState() => _AuthScanPageState();
}

class _AuthScanPageState extends State<AuthScanPage> {
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _isScanningAllowed = true;
  bool _isProcessing = false;
  CameraLensDirection _currentCameraLensDirection = CameraLensDirection.back;

  @override
  void dispose() {
    _isScanningAllowed = false;
    _barcodeScanner.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            CameraPreviewWidget(
              onImageCaptured: (inputImage) => _processAndScanImage(inputImage),
              initialCameraLensDirection: _currentCameraLensDirection,
              onCameraLensDirectionChanged: (newDirection) => setState(() => _currentCameraLensDirection = newDirection),
            ),
            Align(alignment: Alignment.topCenter, child: TopBar("扫描二维码")),
          ],
        ),
      ),
    );
  }

  /// 处理并扫描图像
  /// [context] 当前上下文
  /// [inputImage] 输入的图像
  Future<void> _processAndScanImage(InputImage inputImage) async {
    if (!_isScanningAllowed || _isProcessing) return;

    _isProcessing = true;
    final scannedBarcodes = await _barcodeScanner.processImage(inputImage);

    if (scannedBarcodes.isNotEmpty) {
      int? resultCode = await _handleScannedQRCode(scannedBarcodes);
      if (resultCode == 0) {
        _isScanningAllowed = false;
        Get.until((route) => Get.currentRoute == "/");
        _showScanResultAlert("扫描结果", "添加成功");
      } else {
        await Future.delayed(Duration(seconds: 1));
      }
    }

    _isProcessing = false;
    if (mounted) setState(() {});
  }

  /// 处理扫描到的 QR 码
  ///
  /// [scannedBarcodes] 扫描到的条形码列表
  Future<int?> _handleScannedQRCode(List<Barcode> scannedBarcodes) {
    return handleQRCode(scannedBarcodes);
  }

  /// 显示扫描结果提示框
  ///
  /// [title] 提示框标题
  /// [message] 提示框消息
  void _showScanResultAlert(String title, String message) {
    Get.generalDialog(
      pageBuilder: (context, animation, secondaryAnimation) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(child: Text('确定'), onPressed: () => Get.back()),
          ],
        );
      },
    );
  }
}
