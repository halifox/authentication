import 'package:auth/top_bar.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final MobileScannerController controller = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

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
      appBar: TopBar(
        context,
        '扫描',
        rightIcon: controller.torchEnabled ? Icons.flash_off : Icons.flash_on,
        rightOnPressed: (context) async => controller.toggleTorch(),
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: (BarcodeCapture? barcodeCapture) async {
          Navigator.pop(context, barcodeCapture);
        },
      ),
    );
  }
}
