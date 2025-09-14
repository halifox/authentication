import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sembast/sembast.dart';

import '../l10n/app_localizations.dart';
import '../repository/auth.dart';
import '../repository/repository.dart';
import 'result_screen.dart';
import 'top_bar.dart';

class AddScreenOption {
  AddScreenOption(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final void Function(BuildContext context) onTap;
}

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  late final MobileScannerController controller = MobileScannerController();

  List<AddScreenOption> get options {
    return [
      AddScreenOption(Icons.camera_enhance, AppLocalizations.of(context)!.scanQRCode, scan),
      AddScreenOption(Icons.photo_library, AppLocalizations.of(context)!.uploadQRCode, upload),
      AddScreenOption(Icons.keyboard, AppLocalizations.of(context)!.enterKey, enter),
      AddScreenOption(Icons.file_upload_outlined, AppLocalizations.of(context)!.importFromClipboard, restore),
      AddScreenOption(Icons.file_download_outlined, AppLocalizations.of(context)!.exportToClipboard, backup),
    ];
  }

  Future<void> scan(BuildContext context) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) => ResultScreen(
          state: 0,
          title: AppLocalizations.of(context)!.tip,
          message: AppLocalizations.of(context)!.platformNotSupported,
        ),
      );
      return;
    }
    final BarcodeCapture? barcodeCapture = await Navigator.pushNamed(context, '/scan') as BarcodeCapture?;
    handleScannedBarcodes(context, barcodeCapture?.barcodes);
  }

  Future<void> upload(BuildContext context) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) => ResultScreen(
          state: 0,
          title: AppLocalizations.of(context)!.tip,
          message: AppLocalizations.of(context)!.platformNotSupported,
        ),
      );
      return;
    }
    final XFile? selectedFile = await openFile(
      acceptedTypeGroups: [
        const XTypeGroup(extensions: ['jpg', 'jpeg', 'png']),
      ],
    );
    if (selectedFile == null) {
      //没有选择图片
      return;
    }
    final BarcodeCapture? barcodeCapture = await controller.analyzeImage(selectedFile.path);
    handleScannedBarcodes(context, barcodeCapture?.barcodes);
  }

  Future<void> enter(BuildContext context) async {
    Navigator.pushNamed(context, '/from');
  }

  Future<void> restore(BuildContext context) async {
    final ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData == null) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) => ResultScreen(
          state: 0,
          title: AppLocalizations.of(context)!.importFailed,
          message: AppLocalizations.of(context)!.cannotGetClipboardData,
        ),
      );
      return;
    }
    final String? text = clipboardData.text;
    if (text == null) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) => ResultScreen(
          state: 0,
          title: AppLocalizations.of(context)!.importFailed,
          message: AppLocalizations.of(context)!.cannotGetClipboardData,
        ),
      );
      return;
    }

    final List<String> optUrls = text.split('\n');
    for (final String optUrl in optUrls) {
      final AuthConfig config = AuthConfig.parse(optUrl);
      final bool verify = config.verify(context);
      if (!verify) {
        continue;
      }
      final int count = await authStore.count(
        db,
        filter: Filter.and([Filter.equals('account', config.account), Filter.equals('issuer', config.issuer)]),
      );
      if (count > 0) {
        await authStore.update(
          db,
          config.toJson(),
          finder: Finder(
            filter: Filter.and([Filter.equals('account', config.account), Filter.equals('issuer', config.issuer)]),
          ),
        );
      } else {
        await authStore.add(db, config.toJson());
      }
    }
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => ResultScreen(
        state: 1,
        title: AppLocalizations.of(context)!.importSuccess,
        message: AppLocalizations.of(context)!.importedCount(optUrls.length),
      ),
    );
  }

  Future<void> backup(context) async {
    final List<RecordSnapshot<String, Map<String, Object?>>> records = await authStore.find(db);
    final String optUrls = records.map((e) => AuthConfig.fromJson(e).toOtpUri()).join('\n');
    Clipboard.setData(ClipboardData(text: optUrls));
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => ResultScreen(
        state: 1,
        title: AppLocalizations.of(context)!.exportSuccess,
        message: AppLocalizations.of(context)!.exportedCount(records.length),
      ),
    );
  }

  Future<void> handleScannedBarcodes(BuildContext context, List<Barcode>? barcodes) async {
    if (barcodes == null || barcodes.isEmpty) {
      return;
    }
    final Barcode barcode = barcodes[0];
    final String? uriString = barcode.rawValue;
    if (uriString == null) {
      return;
    }
    Navigator.popUntil(context, ModalRoute.withName('/'));
    final AuthConfig config = AuthConfig.parse(uriString);
    final bool verify = config.verify(context);
    if (!verify) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) => ResultScreen(
          state: 0,
          title: AppLocalizations.of(context)!.tip,
          message: AppLocalizations.of(context)!.unsupportedQRCode,
        ),
      );
      return;
    }
    final int count = await authStore.count(
      db,
      filter: Filter.and([Filter.equals('account', config.account), Filter.equals('issuer', config.issuer)]),
    );
    if (count > 0) {
      final bool? result = await showCupertinoModalPopup<bool?>(
        context: context,
        builder: (ctx) => ResultScreen(
          state: 0,
          title: AppLocalizations.of(context)!.warning,
          message: AppLocalizations.of(context)!.tokenExists(config.issuer, config.account),
          falseButtonVisible: true,
        ),
      );
      if (result == null) {
        return;
      }
      if (result) {
        await authStore.update(
          db,
          config.toJson(),
          finder: Finder(
            filter: Filter.and([Filter.equals('account', config.account), Filter.equals('issuer', config.issuer)]),
          ),
        );
      }
      return;
    }
    await authStore.add(db, config.toJson());

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => ResultScreen(
        state: 1,
        title: AppLocalizations.of(context)!.tip,
        message: AppLocalizations.of(context)!.addSuccess,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(context, AppLocalizations.of(context)!.add),
      body: GridView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 700,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          mainAxisExtent: 90,
        ),
        itemCount: options.length,
        itemBuilder: (context, index) {
          final AddScreenOption option = options[index];
          return HorizontalBarButton(option.icon, option.label, option.onTap);
        },
      ),
    );
  }
}

class HorizontalBarButton extends StatelessWidget {
  const HorizontalBarButton(this.icon, this.label, this.onTap, {super.key});

  final IconData icon;
  final String label;
  final void Function(BuildContext context) onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onTap.call(context),
    child: Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: const BorderRadius.all(Radius.circular(24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 48,
            width: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: Icon(icon, size: 24, color: Theme.of(context).colorScheme.onPrimary),
          ),
          const SizedBox(width: 16),
          Text(
            label,
            maxLines: 1,
            style: TextStyle(
              height: 0,
              fontSize: 18,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
    ),
  );
}
