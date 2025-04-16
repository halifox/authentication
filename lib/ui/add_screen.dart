import 'dart:convert';
import 'dart:html' as html;
import 'dart:io';

import 'package:auth/auth.dart';
import 'package:auth/dialog.dart';
import 'package:auth/repository.dart';
import 'package:auth/top_bar.dart';
import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
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
    [Icons.keyboard, '输入提供的密钥', enterKey],
    [Icons.file_upload_outlined, '导入', restoreBackup],
    [Icons.file_download_outlined, '导出', backup],
  ];

  scanQrCode(context) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      Navigator.pushNamed(context, '/scan');
    } else {
      showAlertDialog(context, '提示', '该功能当前仅支持 Android 和 iOS 平台。');
    }
  }

  uploadQrCode(context) async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      const XTypeGroup imageTypes = XTypeGroup(extensions: <String>['jpg', 'jpeg', 'png']);
      final XFile? selectedFile = await openFile(acceptedTypeGroups: <XTypeGroup>[imageTypes]);

      if (selectedFile == null) {
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

  enterKey(context) {
    Navigator.pushNamed(context, '/from');
  }

  restoreBackup(context) async {
    const XTypeGroup imageTypes = XTypeGroup(extensions: <String>['pa']);
    final XFile? selectedFile = await openFile(acceptedTypeGroups: <XTypeGroup>[imageTypes]);
    if (selectedFile == null) {
      return;
    }
    var json = await selectedFile.readAsString();
    var data = jsonDecode(json) as List;
    for (var item in data) {
      authStore.record(item['key']).put(db, item);
    }
    showAlertDialog(context, "导入成功", "导入完成");
  }

  backup(context) async {
    var filename = 'backup-${DateTime.now().millisecondsSinceEpoch}.pa';
    var records = await authStore.find(db);
    var data =
        records.map((e) {
          var map = Map.from(e.value);
          map['key'] = e.key;
          return map;
        }).toList();
    var json = jsonEncode(data);
    if (kIsWeb) {
      final bytes = utf8.encode(json);
      final blob = html.Blob([Uint8List.fromList(bytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      html.AnchorElement(href: url)
        ..setAttribute("download", filename)
        ..click();
      html.Url.revokeObjectUrl(url);
      showAlertDialog(context, "导出成功", "文件位置:查看浏览器下载记录");
    } else {
      final Directory dir = await getApplicationDocumentsDirectory();
      await dir.create(recursive: true);
      final String path = join(dir.path, filename);
      var file = File(path);
      await file.writeAsString(json);
      showAlertDialog(context, "导出成功", "文件位置:${path}");
    }
  }

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
          final item = options[index];
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
