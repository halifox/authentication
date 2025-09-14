import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../l10n/app_localizations.dart';
import 'top_bar.dart';

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
        AppLocalizations.of(context)!.scan,
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
