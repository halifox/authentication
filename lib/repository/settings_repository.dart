import 'package:shared_preferences/shared_preferences.dart';

/// 设置存储库，负责统一管理基于 SharedPreferences 的应用配置。
class SettingsRepository {
  SettingsRepository(this._prefs);

  final SharedPreferences _prefs;

  // Keys
  static const String _kBiometricUnlock = 'biometric_unlock';
  static const String _kShowCaptchaOnTap = 'is_show_captcha_on_tap';
  static const String _kCopyCaptchaOnTap = 'is_copy_captcha_on_tap';

  // --- Biometric Unlock ---

  /// 获取生物识别解锁开启状态，默认为 false。
  bool get biometricUnlock => _prefs.getBool(_kBiometricUnlock) ?? false;

  /// 设置生物识别解锁开启状态。
  Future<void> setBiometricUnlock(bool value) => _prefs.setBool(_kBiometricUnlock, value);

  // --- Show Captcha On Tap ---

  /// 获取是否点击显示验证码，默认为 false。
  bool get showCaptchaOnTap => _prefs.getBool(_kShowCaptchaOnTap) ?? false;

  /// 设置是否点击显示验证码。
  Future<void> setShowCaptchaOnTap(bool value) => _prefs.setBool(_kShowCaptchaOnTap, value);

  // --- Copy Captcha On Tap ---

  /// 获取是否点击复制验证码，默认为 false。
  bool get copyCaptchaOnTap => _prefs.getBool(_kCopyCaptchaOnTap) ?? false;

  /// 设置是否点击复制验证码。
  Future<void> setCopyCaptchaOnTap(bool value) => _prefs.setBool(_kCopyCaptchaOnTap, value);
}
