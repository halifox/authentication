import 'package:flutter/material.dart';

class LargeButtonOption {
  IconData? icon;
  String label;
  void Function(BuildContext)? onTap;

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
  final IconData? icon;
  final String label;
  final void Function(BuildContext)? onTap;

  const LargeButtonWidget(this.icon, this.label, this.onTap, {super.key});

  @override
  Widget build(BuildContext context) {
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
