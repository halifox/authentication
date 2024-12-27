import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:purity_auth/auth.dart';
import 'package:purity_auth/auth_repository.dart';
import 'package:purity_auth/dialog.dart';
import 'package:purity_auth/top_bar.dart';
import 'package:purity_auth/window_size_controller.dart';

class AuthAddPage extends StatefulWidget {
  const AuthAddPage({super.key});

  @override
  State<AuthAddPage> createState() => _AuthAddPageState();
}

class _AuthAddPageState extends State<AuthAddPage> with WidgetsBindingObserver, WindowSizeStateMixin {
  late final List<AuthAddButtonOption> options = <AuthAddButtonOption>[
    AuthAddButtonOption(icon: Icons.camera_enhance, label: '扫描二维码', onTap: scanQrCode),
    AuthAddButtonOption(icon: Icons.photo_library, label: '上传二维码', onTap: uploadQrCode),
    AuthAddButtonOption(icon: Icons.edit, label: '输入提供的密钥', onTap: enterKey),
    AuthAddButtonOption(icon: Icons.restore, label: '从备份中恢复', onTap: restoreBackup),
    AuthAddButtonOption(icon: Icons.format_list_numbered, label: '从其他应用导入', onTap: importFromApps),
  ];

  void scanQrCode(BuildContext context) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      Navigator.pushNamed(context, '/AuthScanPage');
    } else {
      showAlertDialog(context, '提示', '该功能当前仅支持 Android 和 iOS 平台。');
    }
  }

  void uploadQrCode(BuildContext context) async {
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
        final AuthenticationConfig config = AuthenticationConfig.parse(rawValue);
        await GetIt.I<AuthRepository>().insert(config);
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

  void enterKey(BuildContext context) {
    Navigator.pushNamed(context, '/AuthFromPage');
  }

  void restoreBackup(BuildContext context) {
    showDevDialog(context);
  }

  void importFromApps(BuildContext context) {
    showDevDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: contentWidth,
            child: Column(
              children: <Widget>[
                TopBar(context, '添加'),
                Expanded(
                  child: GridView.builder(
                    physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: maxCrossAxisExtent,
                      mainAxisExtent: 90,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                    ),
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final AuthAddButtonOption option = options[index];
                      return buildAuthAddButton(option.icon, option.label, option.onTap);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildAuthAddButton(
    IconData? icon,
    String label,
    void Function(BuildContext)? onTap,
  ) {
    return GestureDetector(
      onTap: () => onTap?.call(context),
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
              child: Icon(icon, size: 24, color: Theme.of(context).colorScheme.onPrimary),
            ),
            const SizedBox(width: 16),
            Text(label, maxLines: 1, style: TextStyle(height: 0, fontSize: 18, color: Theme.of(context).colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

class AuthAddButtonOption {
  IconData? icon;
  String label;
  void Function(BuildContext)? onTap;

  /// 创建 [AuthAddButtonOption] 的构造函数。
  ///
  /// [icon] 参数指定图标的字符串表示。
  /// [label] 参数指定标签的字符串表示。
  /// [onTap] 参数指定一个函数，该函数接受一个 [] 类型的参数，并返回 void，用于处理用户交互。
  AuthAddButtonOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
