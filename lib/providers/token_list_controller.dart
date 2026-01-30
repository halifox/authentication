import 'package:auth/router/app_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'token_list_controller.g.dart';

/// 令牌列表页面的控制器，处理页面导航逻辑。
@riverpod
class TokenListController extends _$TokenListController {
  @override
  void build() {}

  /// 跳转到添加账号页面。
  void navigateToAddAccount() {
    ref.read(routerProvider).pushNamed(AppRoutes.addName);
  }

  /// 跳转到设置页面。
  void navigateToSettings() {
    ref.read(routerProvider).pushNamed(AppRoutes.settingsName);
  }
}
