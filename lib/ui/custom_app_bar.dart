import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 自定义应用栏，提供一致的顶部导航样式。
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 创建一个自定义应用栏。
  /// [title] 标题文字。
  /// [leftIcon] 左侧按钮图标，默认为返回箭头。
  /// [leftOnPressed] 左侧按钮点击回调。
  /// [rightIcon] 右侧按钮图标。
  /// [rightOnPressed] 右侧按钮点击回调。
  const CustomAppBar({
    super.key,
    required this.title,
    this.leftIcon = Icons.arrow_back,
    this.leftOnPressed = _defaultLeftOnPressed,
    this.rightIcon,
    this.rightOnPressed,
  });

  /// 标题内容
  final String title;
  /// 左侧图标
  final IconData? leftIcon;
  /// 左侧点击回调
  final void Function(BuildContext context)? leftOnPressed;
  /// 右侧图标
  final IconData? rightIcon;
  /// 右侧点击回调
  final void Function(BuildContext context)? rightOnPressed;

  /// 默认的左侧返回操作
  static void _defaultLeftOnPressed(BuildContext context) {
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            AppBarIconButton(
              icon: leftIcon,
              onPressed: () => leftOnPressed?.call(context),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            AppBarIconButton(
              icon: rightIcon,
              onPressed: rightOnPressed != null ? () => rightOnPressed!(context) : null,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

/// 应用栏使用的自定义图标按钮，具有圆角和特定配色。
class AppBarIconButton extends StatelessWidget {
  /// 创建一个应用栏图标按钮。
  /// [icon] 图标。
  /// [onPressed] 点击回调。
  const AppBarIconButton({
    super.key,
    this.icon,
    this.onPressed,
  });

  /// 图标数据
  final IconData? icon;
  /// 点击回调
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: icon != null,
      replacement: const SizedBox(width: 64, height: 64),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          fixedSize: const Size(64, 64),
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
        ),
        child: icon != null
            ? Icon(icon, size: 30, color: Theme.of(context).colorScheme.onPrimaryContainer)
            : null,
      ),
    );
  }
}
