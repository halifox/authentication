import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purity_auth/image_tools.dart';
import 'package:purity_auth/large_button_widget.dart';
import 'package:purity_auth/top_bar.dart';
import 'package:purity_auth/window_size_controller.dart';

class AuthAddPage extends StatelessWidget {
  AuthAddPage({super.key});

  final windowSizeController = Get.put(WindowSizeController());

  late final List<LargeButtonOption> options = [
    LargeButtonOption(icon: Icons.camera_enhance, label: "扫描二维码", onTap: scanQrCode),
    LargeButtonOption(icon: Icons.photo_library, label: "上传二维码", onTap: uploadQrCode),
    LargeButtonOption(icon: Icons.edit, label: "输入提供的密钥", onTap: enterKey),
    LargeButtonOption(icon: Icons.restore, label: "从备份中恢复", onTap: restoreBackup),
    LargeButtonOption(icon: Icons.format_list_numbered, label: "从其他应用导入", onTap: importFromApps),
  ];

  void scanQrCode(BuildContext context) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      Get.toNamed("/AuthScanPage");
    } else {
      showPlatformSupportDialog(context);
    }
  }

  void uploadQrCode(BuildContext context) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      selectAndProcessQRCode();
    } else {
      showPlatformSupportDialog(context);
    }
  }

  void enterKey(BuildContext context) {
    Get.toNamed("/AuthFromPage");
  }

  void restoreBackup(BuildContext context) {}

  void importFromApps(BuildContext context) {}

  void showPlatformSupportDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
        return AlertDialog(
          title: Text('提示'),
          content: Text('该功能当前仅支持 Android 和 iOS 平台。'),
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text('确定'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Obx(
            () => SizedBox(
              width: windowSizeController.contentWidth.value,
              child: Column(
                children: [
                  TopBar(context, "添加"),
                  Expanded(
                    child: GridView.builder(
                      physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: windowSizeController.maxCrossAxisExtent,
                        mainAxisExtent: 90,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options[index];
                        return LargeButtonWidget(option.icon, option.label, option.onTap, key: ObjectKey(option));
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
