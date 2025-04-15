import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:auth/auth.dart';
import 'package:auth/repository.dart';
import 'package:auth/dialog.dart';
import 'package:auth/top_bar.dart';
import 'package:sembast/sembast.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> with WidgetsBindingObserver {
  late final options = [
    [Icons.camera_enhance, '扫描二维码', scanQrCode],
    [Icons.photo_library, '上传二维码', uploadQrCode],
    [Icons.edit, '输入提供的密钥', enterKey],
    [Icons.restore, '从备份中恢复', restoreBackup],
    [Icons.format_list_numbered, '从其他应用导入', importFromApps],
  ];

   scanQrCode(BuildContext context) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      Navigator.pushNamed(context, '/AuthScanPage');
    } else {
      showAlertDialog(context, '提示', '该功能当前仅支持 Android 和 iOS 平台。');
    }
  }

   uploadQrCode(BuildContext context) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      const XTypeGroup imageTypes = XTypeGroup(extensions: <String>['jpg', 'jpeg', 'png']);
      final XFile? selectedFile = await openFile(acceptedTypeGroups: <XTypeGroup>[imageTypes]);

      if (selectedFile == null) {
        showAlertDialog(context, '上传二维码', '未选择图片');
        return;
      }

      final InputImage inputImage = InputImage.fromFilePath(selectedFile.path);
      final BarcodeScanner barcodeScanner = BarcodeScanner(formats: <BarcodeFormat>[BarcodeFormat.qrCode]);
      final List<Barcode> barcodes = await barcodeScanner.processImage(inputImage);

      //todo 这里弹出一个新的窗口 用于确认扫描结果 如果扫描到多个 可以手动选择
      if (barcodes.isEmpty) {
        showAlertDialog(context, '扫描结果', '未识别到二维码');
        return;
      }
      if (barcodes.length > 1) {
        showAlertDialog(context, '扫描结果', '识别到多个二维码');
        return;
      }

      try {
        final Barcode barcode = barcodes.first;
        final String rawValue = barcode.rawValue ?? '';
        final AuthConfig config = AuthConfig.parse(rawValue);
        authStore.add(db, config.toJson());
        return;
      } on ArgumentError catch (e) {
        showAlertDialog(context, '参数错误', e.message as String?);
        return;
      } on FormatException catch (e) {
        showAlertDialog(context, '格式错误', e.message);
        return;
      } catch (e) {
        showAlertDialog(context, '未知错误', e.toString());
        return;
      }
    } else {
      showAlertDialog(context, '提示', '该功能当前仅支持 Android 和 iOS 平台。');
    }
  }

   enterKey(BuildContext context) {
    Navigator.pushNamed(context, '/AuthFromPage');
  }

   restoreBackup(BuildContext context) {
    showDevDialog(context);
  }

   importFromApps(BuildContext context) {
    showDevDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TopBar(context, '添加'),
      body: GridView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 700, mainAxisSpacing: 16, crossAxisSpacing: 16, mainAxisExtent: 90),
        itemCount: options.length,
        itemBuilder: (BuildContext context, int index) {
          final List<Object> option = options[index];
          return _Button(option[0] as IconData?, option[1] as String, option[2] as void Function(BuildContext p1)?);
        },
      ),
    );
  }
}

class _Button extends StatefulWidget {
  _Button(this.icon, this.label, this.onTap, {super.key});

  IconData? icon;
  String label;
  void Function(BuildContext)? onTap;

  @override
  State<_Button> createState() => _ButtonState();
}

class _ButtonState extends State<_Button> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap?.call(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primaryContainer, borderRadius: const BorderRadius.all(Radius.circular(24))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 48,
              width: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: const BorderRadius.all(Radius.circular(12))),
              child: Icon(widget.icon, size: 24, color: Theme.of(context).colorScheme.onPrimary),
            ),
            const SizedBox(width: 16),
            Text(widget.label, maxLines: 1, style: TextStyle(height: 0, fontSize: 18, color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
