import 'package:flutter/material.dart';
import 'package:get/get.dart';

double _TopBarIconSize = 30;
double _TopBarIconButtonSize = 64;

/// 默认的左侧按钮回调函数，关闭当前页面。
void defaultLeftOnPressed() {
  Get.back();
}

/// 默认的右侧按钮回调函数，当前未实现任何操作。
void defaultRightOnPressed() {}

/// 创建一个顶部导航栏组件。
/// [title] 导航栏标题，类型为 [String]。
/// [leftIcon] 左侧图标，类型为 [IconData?]，默认为 [Icons.arrow_back]。
/// [leftOnPressed] 左侧图标的点击回调，类型为 [void Function()?]，默认为 [defaultLeftOnPressed]。
/// [rightIcon] 右侧图标，类型为 [IconData?]。
/// [rightOnPressed] 右侧图标的点击回调，类型为 [void Function()?]，默认为 [defaultRightOnPressed]。
/// 返回值为导航栏的 [Widget] 组件。
Widget TopBar(
  final BuildContext context,
  String title, {
  IconData? leftIcon = Icons.arrow_back,
  GestureTapCallback? leftOnPressed = defaultLeftOnPressed,
  IconData? rightIcon,
  GestureTapCallback? rightOnPressed = defaultRightOnPressed,
}) {
  return Padding(
    padding: EdgeInsets.all(16),
    child: Row(
      children: [
        TopBarIconButton(context, leftIcon, () => leftOnPressed?.call()),
        Spacer(),
        TopBarTitle(context, title),
        Spacer(),
        TopBarIconButton(context, rightIcon, () => rightOnPressed?.call()),
      ],
    ),
  );
}

/// 创建一个顶部导航栏的标题组件。
/// [data] 导航栏标题文本，类型为 [String]。
/// 返回值为标题的 [Widget] 组件。
Widget TopBarTitle(
  final BuildContext context,
  final String data,
) {
  return Text(
    data,
    style: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    ),
  );
}

/// 创建一个顶部导航栏图标按钮组件。
/// [icon] 图标，类型为 [IconData?]。
/// [onPressed] 点击回调，类型为 [VoidCallback?]。
/// 返回值为图标按钮的 [Widget] 组件。
Widget TopBarIconButton(
  final BuildContext context,
  final IconData? icon,
  final VoidCallback? onPressed,
) {
  return Visibility(
    visible: icon != null,
    replacement: TopBarIconButtonPlaceholder(),
    child: ElevatedButton(
      onPressed: onPressed,
      child: Icon(
        icon,
        size: _TopBarIconSize,
        color: Theme.of(context).colorScheme.onPrimaryContainer,
      ),
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        fixedSize: Size(_TopBarIconButtonSize, _TopBarIconButtonSize),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    ),
  );
}

/// 创建一个顶部导航栏图标按钮的占位符组件。
/// 返回值为占位符的 [Widget] 组件。
Widget TopBarIconButtonPlaceholder() {
  return SizedBox(
    width: _TopBarIconButtonSize,
    height: _TopBarIconButtonSize,
  );
}
