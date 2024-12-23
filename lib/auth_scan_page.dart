import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:purity_auth/auth.dart';
import 'package:purity_auth/auth_add_page.dart';
import 'package:purity_auth/camera_preview_widget.dart';
import 'package:purity_auth/top_bar.dart';

import 'auth_repository.dart';

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
              onImageCaptured: (inputImage) => _processAndScanImage(context, inputImage),
              initialCameraLensDirection: _currentCameraLensDirection,
              onCameraLensDirectionChanged: (newDirection) => setState(() => _currentCameraLensDirection = newDirection),
            ),
            Align(alignment: Alignment.topCenter, child: TopBar(context, "扫描二维码")),
          ],
        ),
      ),
    );
  }

  /// 处理并扫描图像
  /// [context] 当前上下文
  /// [inputImage] 输入的图像
  Future<void> _processAndScanImage(BuildContext context, InputImage inputImage) async {
    if (!_isScanningAllowed || _isProcessing) return;

    _isProcessing = true;
    final barcodes = await _barcodeScanner.processImage(inputImage);

    if (barcodes.isNotEmpty) {
      if (barcodes.length > 1) {
        showAlertDialog(context, "扫描结果", "识别到多个二维码");
        return;
      }

      try {
        final Barcode barcode = barcodes.first;
        final String rawValue = barcode.rawValue ?? "";
        final AuthenticationConfig config = AuthenticationConfig.parse(rawValue);
        await GetIt.I<AuthRepository>().upsert(config);

        _isScanningAllowed = false;
        Navigator.popUntil(context, (route) => route.settings.name == "/");
        showAlertDialog(context, "扫描结果", "添加成功");

        return;
      } on ArgumentError catch (e) {
        showAlertDialog(context, "参数错误", e.message);
        return;
      } on FormatException catch (e) {
        showAlertDialog(context, "格式错误", e.message);
        return;
      } catch (e) {
        showAlertDialog(context, "未知错误", e.toString());
        return;
      }
    }
    await Future.delayed(Duration(seconds: 1));
    _isProcessing = false;
    if (mounted) setState(() {});
  }
}
