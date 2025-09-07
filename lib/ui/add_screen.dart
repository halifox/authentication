import 'dart:io';

import 'package:auth/auth.dart';
import 'package:auth/repository.dart';
import 'package:auth/top_bar.dart';
import 'package:auth/ui/result_screen.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sembast/sembast.dart';

class AddScreenOption {
  AddScreenOption(this.icon, this.label, this.onTap);

  final IconData icon;
  final String label;
  final void Function(BuildContext context) onTap;
}

class AddScreen extends StatelessWidget {
  final MobileScannerController controller = MobileScannerController();

  late final List<AddScreenOption> options = [
    AddScreenOption(Icons.camera_enhance, '扫描二维码', scan),
    AddScreenOption(Icons.photo_library, '上传二维码', upload),
    AddScreenOption(Icons.keyboard, '输入密钥', enter),
    AddScreenOption(Icons.file_upload_outlined, '从剪贴板导入', restore),
    AddScreenOption(Icons.file_download_outlined, '导出到剪贴板', backup),
  ];

  void scan(BuildContext context) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) => ResultScreen(state: 0, title: '提示', message: '该功能当前仅支持 Android 和 iOS 平台。'),
      );
      return;
    }
    final BarcodeCapture? barcodeCapture = await Navigator.pushNamed(context, '/scan') as BarcodeCapture?;
    handleScannedBarcodes(context, barcodeCapture?.barcodes);
  }

  void upload(BuildContext context) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) => ResultScreen(state: 0, title: '提示', message: '该功能当前仅支持 Android 和 iOS 平台。'),
      );
      return;
    }
    final XFile? selectedFile = await openFile(
      acceptedTypeGroups: [
        XTypeGroup(extensions: ['jpg', 'jpeg', 'png']),
      ],
    );
    if (selectedFile == null) {
      //没有选择图片
      return;
    }
    final BarcodeCapture? barcodeCapture = await controller.analyzeImage(selectedFile.path);
    handleScannedBarcodes(context, barcodeCapture?.barcodes);
  }

  void enter(BuildContext context) async {
    Navigator.pushNamed(context, '/from');
  }

  void restore(BuildContext context) async {
    final ClipboardData? clipboardData = await Clipboard.getData('text/plain');
    if (clipboardData == null) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) => ResultScreen(state: 0, title: "导入失败", message: "无法获取剪贴板数据"),
      );
      return;
    }
    final String? text = clipboardData.text;
    if (text == null) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) => ResultScreen(state: 0, title: "导入失败", message: "无法获取剪贴板数据"),
      );
      return;
    }

    List<String> optUrls = text.split("\n");
    for (String optUrl in optUrls) {
      final AuthConfig config = AuthConfig.parse(optUrl);
      final bool verify = config.verify();
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
      builder: (ctx) => ResultScreen(state: 1, title: "导入成功", message: "共导入${optUrls.length}条数据"),
    );
  }

  void backup(context) async {
    final List<RecordSnapshot<String, Map<String, Object?>>> records = await authStore.find(db);
    final String optUrls = records.map((e) => AuthConfig.fromJson(e).toOtpUri()).join("\n");
    Clipboard.setData(ClipboardData(text: optUrls));
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => ResultScreen(state: 1, title: "导出成功", message: "共导出${records.length}条数据到剪贴板"),
    );
  }

  void handleScannedBarcodes(BuildContext context, List<Barcode>? barcodes) async {
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
    final bool verify = config.verify();
    if (!verify) {
      showCupertinoModalPopup(
        context: context,
        builder: (ctx) => ResultScreen(state: 0, title: '提示', message: '暂不支持此类型的二维码链接，请确认来源是否正确。'),
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
          title: '警告',
          message: '令牌${config.issuer}:${config.account}已经存在,是否覆盖它',
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
      builder: (ctx) => ResultScreen(state: 1, title: '提示', message: '添加成功'),
    );
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: TopBar(context, '添加'),
      body: GridView.builder(
        physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap.call(context),
      child: Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(24)),
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
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: Icon(icon, size: 24, color: Theme.of(context).colorScheme.onPrimary),
            ),
            SizedBox(width: 16),
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
            SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
