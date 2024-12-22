import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LargeButtonOption {
  String icon;
  String label;
  GestureTapCallback? onTap;

  /// 创建 [LargeButtonOption] 的构造函数。
  ///
  /// [icon] 参数指定图标的字符串表示。
  /// [label] 参数指定标签的字符串表示。
  /// [onTap] 参数指定一个函数，该函数接受一个 [] 类型的参数，并返回 void，用于处理用户交互。
  LargeButtonOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class LargeButtonWidget extends StatelessWidget {
  final String icon;
  final String label;
  final GestureTapCallback? onTap;

  LargeButtonWidget(this.icon, this.label, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Get.theme.colorScheme.primaryContainer, borderRadius: BorderRadius.all(Radius.circular(24))),
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
            Text(label, maxLines: 1, style: TextStyle(height: 0, fontSize: 18, color: Get.theme.colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold)),
            SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
