import 'package:auth/db/database.dart';
import 'package:auth/ui/add_account_screen.dart';
import 'package:auth/ui/icon_selection_screen.dart';
import 'package:auth/ui/qr_scanner_screen.dart';
import 'package:auth/ui/settings_screen.dart';
import 'package:auth/ui/token_form_screen.dart';
import 'package:auth/ui/token_list_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

/// 全局路由配置提供者
@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: [
      GoRoute(
        path: AppRoutes.home,
        name: AppRoutes.homeName,
        builder: (context, state) => const TokenListScreen(),
        routes: [
          GoRoute(
            path: 'add',
            name: AppRoutes.addName,
            builder: (context, state) => const AddAccountScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: AppRoutes.settingsName,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: 'form',
            name: AppRoutes.formName,
            builder: (context, state) {
              final authEntry = state.extra as AuthEntry?;
              return TokenFormScreen(initialEntry: authEntry);
            },
          ),
          GoRoute(
            path: 'scan',
            name: AppRoutes.scanName,
            builder: (context, state) => const QrScannerScreen(),
          ),
          GoRoute(
            path: 'icons',
            name: AppRoutes.iconsName,
            builder: (context, state) => const IconSelectionScreen(),
          ),
        ],
      ),
    ],
  );
}

/// 路由名称常量定义，提供基础的类型安全
class AppRoutes {
  static const home = '/';
  static const homeName = 'home';

  static const add = '/add';
  static const addName = 'add';

  static const settings = '/settings';
  static const settingsName = 'settings';

  static const form = '/form';
  static const formName = 'form';

  static const scan = '/scan';
  static const scanName = 'scan';

  static const icons = '/icons';
  static const iconsName = 'icons';
}
