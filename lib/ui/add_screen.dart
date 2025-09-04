import 'dart:convert';
import 'dart:io';

import 'package:auth/auth.dart';
import 'package:auth/dialog.dart';
import 'package:auth/library/io.dart' if (dart.library.html) 'package:auth/library/web.dart';
import 'package:auth/repository.dart';
import 'package:auth/top_bar.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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
    AddScreenOption(Icons.file_upload_outlined, '恢复备份', restore),
    AddScreenOption(Icons.file_download_outlined, '创建备份', backup),
  ];

  void scan(BuildContext context) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      showAlertDialog(context, '提示', '该功能当前仅支持 Android 和 iOS 平台。');
      return;
    }

    final BarcodeCapture? barcodeCapture =
        await Navigator.pushNamed(context, '/scan') as BarcodeCapture?;
    handleScannedBarcodes(context, barcodeCapture?.barcodes);
  }

  void upload(BuildContext context) async {
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      showAlertDialog(context, '提示', '该功能当前仅支持 Android 和 iOS 平台。');
      return;
    }

    var selectedFile = await openFile(
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
    try {
      var selectedFile = await openFile(
        acceptedTypeGroups: [
          XTypeGroup(extensions: <String>['pa']),
        ],
      );
      if (selectedFile == null) {
        return;
      }
      var json = await selectedFile.readAsString();
      var list = jsonDecode(json) as List;
      for (var item in list) {
        authStore.record(item['key']).put(db, item);
      }
      showAlertDialog(context, "导入成功", "导入完成");
    } catch (e) {
      showAlertDialog(context, '错误', e.toString());
    }
  }

  backup(context) async {
    try {
      var filename = generateFileNameWithTime('backup', 'pa');
      var records = await authStore.find(db);
      var data = records.map((e) {
        var map = Map.from(e.value);
        map['key'] = e.key;
        return map;
      }).toList();
      var json = jsonEncode(data);
      await createBackupImpl(context, json, filename);
    } catch (e) {
      showAlertDialog(context, '错误', e.toString());
    }
  }

  String generateFileNameWithTime(String prefix, String extension) {
    var now = DateTime.now();
    var formatted =
        '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
    return '$prefix\_$formatted.$extension';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

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
      showAlertDialog(context, '提示', '暂不支持此类型的二维码链接，请确认来源是否正确。');
      return;
    }
    final int count = await authStore.count(
      db,
      filter: Filter.and([
        Filter.equals('account', config.account),
        Filter.equals('issuer', config.issuer),
      ]),
    );
    if (count > 0) {
      showOverwriteDialog(context, config);
      return;
    }
    await authStore.add(db, config.toJson());
    await showAlertDialog(context, '提示', '添加成功');
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
