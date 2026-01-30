import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import 'package:auth/l10n/generated/app_localizations.dart';
import 'package:auth/ui/custom_app_bar.dart';

/// 二维码扫描页面，使用相机扫描并识别 OTP 二维码。
class QrScannerScreen extends StatefulWidget {
  /// 创建二维码扫描页面。
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController(autoStart: false, detectionSpeed: DetectionSpeed.noDuplicates);

  @override
  void initState() {
    controller.start();
    super.initState();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
          title: AppLocalizations.of(context)!.scan,
          rightIcon: controller.torchEnabled ? Icons.flash_off : Icons.flash_on,
          rightOnPressed: (BuildContext context) async => controller.toggleTorch()),
      body: MobileScanner(
        controller: controller,
        onDetect: (BarcodeCapture? barcodeCapture) async {
          context.pop(barcodeCapture);
        },
      ),
    );
  }
}