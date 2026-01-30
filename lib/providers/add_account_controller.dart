import 'package:auth/router/app_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'add_account_controller.g.dart';

/// 添加账户页面的控制器，处理导航操作。
@riverpod
class AddAccountController extends _$AddAccountController {
  @override
  void build() {}

  /// 导航到手动输入表单页面。
  void enter() {
    ref.read(routerProvider).push(AppRoutes.form);
  }
}
