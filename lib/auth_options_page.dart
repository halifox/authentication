import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purity_auth/image_tools.dart';
import 'package:purity_auth/top_bar.dart';

class AuthOptionsPageController extends GetxController {
  late List<AuthOption> authOptions = [
    AuthOption(iconPath: "icon", labelText: "扫描二维码", onSelect: scanQrCode),
    AuthOption(iconPath: "icon", labelText: "上传二维码", onSelect: uploadQrCode),
    AuthOption(iconPath: "icon", labelText: "输入提供的密钥", onSelect: enterKey),
    AuthOption(iconPath: "icon", labelText: "从备份中恢复", onSelect: restoreBackup),
    AuthOption(iconPath: "icon", labelText: "从其他应用导入", onSelect: importFromApps),
  ];

  scanQrCode() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      Get.toNamed("/AuthScanPage");
    } else {
      showPlatformSupportDialog();
    }
  }

  uploadQrCode() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      selectAndProcessQRCode();
    } else {
      showPlatformSupportDialog();
    }
  }

  enterKey() {
    Get.toNamed("/AuthFromPage");
  }

  restoreBackup() {}

  importFromApps() {}

  showPlatformSupportDialog() {
    Get.generalDialog(
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
}

class AuthOptionsPage extends StatelessWidget {
  final controller = Get.put(AuthOptionsPageController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            TopBar("添加"),
            Expanded(
              child: GridView.builder(
                physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                padding: EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 750,
                  mainAxisExtent: 90,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: controller.authOptions.length,
                itemBuilder: (context, index) {
                  var item = controller.authOptions[index];
                  return AuthOptionWidget(key: ObjectKey(item), option: item);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AuthOption {
  String iconPath;
  String labelText;
  void Function() onSelect;

  /// 创建 [AuthOption] 的构造函数。
  ///
  /// [iconPath] 参数指定图标的字符串表示。
  /// [labelText] 参数指定标签的字符串表示。
  /// [onSelect] 参数指定一个函数，该函数接受一个 [] 类型的参数，并返回 void，用于处理用户交互。
  AuthOption({
    required this.iconPath,
    required this.labelText,
    required this.onSelect,
  });
}

class AuthOptionWidget extends StatelessWidget {
  final AuthOption option;

  const AuthOptionWidget({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => option.onSelect(),
      child: Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 48,
              width: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: Get.theme.colorScheme.primary, borderRadius: BorderRadius.all(Radius.circular(12))),
              child: Icon(Icons.add, size: 24, color: Get.theme.colorScheme.onPrimary),
            ),
            SizedBox(width: 16),
            Text(
              option.labelText,
              maxLines: 1,
              style: TextStyle(height: 0, fontSize: 18, color: Get.theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
