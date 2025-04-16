import 'dart:convert';
import 'dart:io';

import 'package:auth/library/io.dart' if (dart.library.html) 'package:auth/library/web.dart.dart';

import 'package:auth/auth.dart';
import 'package:auth/dialog.dart';
import 'package:auth/repository.dart';
import 'package:auth/top_bar.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:sembast/sembast.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({super.key});

  @override
  State<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends State<AddScreen> {
  late final options = [
    [Icons.camera_enhance, '扫描二维码', scanQrCode],
    [Icons.photo_library, '上传二维码', uploadQrCode],
    [Icons.keyboard, '输入密钥', provideKey],
    [Icons.file_upload_outlined, '恢复备份', loadBackup],
    [Icons.file_download_outlined, '创建备份', createBackup],
  ];

  scanQrCode(context) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      Navigator.pushNamed(context, '/scan');
    } else {
      showAlertDialog(context, '提示', '该功能当前仅支持 Android 和 iOS 平台。');
    }
  }

  uploadQrCode(context) async {
    try {
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        var selectedFile = await openFile(
          acceptedTypeGroups: [
            XTypeGroup(extensions: ['jpg', 'jpeg', 'png']),
          ],
        );
        if (selectedFile == null) {
          return;
        }
        var inputImage = InputImage.fromFilePath(selectedFile.path);
        var barcodeScanner = BarcodeScanner(formats: [BarcodeFormat.qrCode]);
        var barcodes = await barcodeScanner.processImage(inputImage);
        var barcode = barcodes[0];
        var rawValue = barcode.rawValue ?? '';
        var config = AuthConfig.parse(rawValue);
        authStore.add(db, config.toJson());
        return;
      } else {
        showAlertDialog(context, '提示', '该功能当前仅支持 Android 和 iOS 平台。');
      }
    } on ArgumentError catch (e) {
      showAlertDialog(context, '参数错误', e.message);
      return;
    } on FormatException catch (e) {
      showAlertDialog(context, '格式错误', e.message);
      return;
    } catch (e) {
      showAlertDialog(context, '错误', e.toString());
      return;
    }
  }

  provideKey(context) {
    Navigator.pushNamed(context, '/from');
  }

  loadBackup(context) async {
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

  createBackup(context) async {
    try {
      var filename = generateFileNameWithTime('backup', 'pa');
      var records = await authStore.find(db);
      var data =
          records.map((e) {
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
    var formatted = '${now.year}${_twoDigits(now.month)}${_twoDigits(now.day)}_${_twoDigits(now.hour)}${_twoDigits(now.minute)}${_twoDigits(now.second)}';
    return '$prefix\_$formatted.$extension';
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  Widget build(context) {
    return Scaffold(
      appBar: TopBar(context, '添加'),
      body: GridView.builder(
        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 700, mainAxisSpacing: 16, crossAxisSpacing: 16, mainAxisExtent: 90),
        itemCount: options.length,
        itemBuilder: (context, index) {
          var item = options[index];
          return HorizontalBarButton(item[0], item[1], item[2]);
        },
      ),
    );
  }
}

class HorizontalBarButton extends StatefulWidget {
  const HorizontalBarButton(this.icon, this.label, this.onTap, {super.key});

  final icon;
  final label;
  final onTap;

  @override
  State<HorizontalBarButton> createState() => _HorizontalBarButtonState();
}

class _HorizontalBarButtonState extends State<HorizontalBarButton> {
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
