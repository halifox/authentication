import 'package:authentication/l10n/generated/app_localizations.dart';
import 'package:authentication/widgets/app_scaffold.dart';
import 'package:authentication/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController(
    autoStart: false,
    detectionSpeed: DetectionSpeed.noDuplicates,
  );
  bool detected = false;
  bool startupFailed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await controller.start();
      } catch (_) {
        if (mounted) setState(() => startupFailed = true);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ValueListenableBuilder<MobileScannerState>(
      valueListenable: controller,
      builder: (context, state, _) => AppScaffold(
        appBar: CustomAppBar(
          title: l10n.scan,
          rightIcon: state.torchState == TorchState.on
              ? Icons.flash_off
              : Icons.flash_on,
          rightTooltip: state.torchState == TorchState.on
              ? l10n.torchOff
              : l10n.torchOn,
          rightOnPressed: (_) async {
            if (!state.isRunning ||
                state.torchState == TorchState.unavailable) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(l10n.torchUnavailable)));
              return;
            }
            try {
              await controller.toggleTorch();
            } catch (_) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(l10n.torchUnavailable)));
              }
            }
          },
        ),
        body: Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: controller,
              errorBuilder: (_, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    l10n.scannerUnavailable,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              onDetect: (capture) {
                if (detected ||
                    !mounted ||
                    ModalRoute.of(context)?.isCurrent != true ||
                    capture.barcodes.isEmpty) {
                  return;
                }
                detected = true;
                Navigator.pop(context, capture);
              },
            ),
            if (state.isRunning && !startupFailed)
              IgnorePointer(
                child: Center(
                  child: FractionallySizedBox(
                    widthFactor: .72,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 320),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (startupFailed)
              ColoredBox(
                color: Theme.of(context).colorScheme.surface,
                child: Center(child: Text(l10n.scannerUnavailable)),
              ),
          ],
        ),
      ),
    );
  }
}
