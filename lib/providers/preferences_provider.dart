import 'package:auth/repository/settings_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'preferences_provider.g.dart';

/// 异步提供 [SharedPreferences] 实例。
@Riverpod(keepAlive: true)
Future<SharedPreferences> sharedPreferences(Ref ref) async {
  return await SharedPreferences.getInstance();
}

/// 提供 [SettingsRepository] 单例，封装了配置的存取逻辑。
@Riverpod(keepAlive: true)
Future<SettingsRepository> settingsRepository(Ref ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  return SettingsRepository(prefs);
}

/// 管理生物识别解锁偏好的状态。
@Riverpod(keepAlive: true)
class BiometricUnlock extends _$BiometricUnlock {
  @override
  bool build() => ref.watch(settingsRepositoryProvider).value?.biometricUnlock ?? false;

  /// 更新并持久化生物识别解锁偏好。
  Future<void> update(bool value) async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.setBiometricUnlock(value);
    state = value;
  }
}

/// 管理“点击显示验证码”偏好的状态。
@Riverpod(keepAlive: true)
class IsShowCaptchaOnTap extends _$IsShowCaptchaOnTap {
  @override
  bool build() => ref.watch(settingsRepositoryProvider).value?.showCaptchaOnTap ?? false;

  /// 更新并持久化“点击显示验证码”偏好。
  Future<void> update(bool value) async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.setShowCaptchaOnTap(value);
    state = value;
  }
}

/// 管理“点击复制验证码”偏好的状态。
@Riverpod(keepAlive: true)
class IsCopyCaptchaOnTap extends _$IsCopyCaptchaOnTap {
  @override
  bool build() => ref.watch(settingsRepositoryProvider).value?.copyCaptchaOnTap ?? false;

  /// 更新并持久化“点击复制验证码”偏好。
  Future<void> update(bool value) async {
    final repo = await ref.read(settingsRepositoryProvider.future);
    await repo.setCopyCaptchaOnTap(value);
    state = value;
  }
}
