import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

class IsShowCaptchaOnTap extends Notifier<bool> {
  @override
  bool build() =>
      ref
          .watch(sharedPreferencesProvider)
          .value
          ?.getBool('is_show_captcha_on_tap') ??
      false;

  Future<void> update(bool value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool('is_show_captcha_on_tap', value);
    state = value;
  }
}

class IsCopyCaptchaOnTap extends Notifier<bool> {
  @override
  bool build() =>
      ref
          .watch(sharedPreferencesProvider)
          .value
          ?.getBool('is_copy_captcha_on_tap') ??
      false;

  Future<void> update(bool value) async {
    final prefs = await ref.read(sharedPreferencesProvider.future);
    await prefs.setBool('is_copy_captcha_on_tap', value);
    state = value;
  }
}

final isShowCaptchaOnTapProvider = NotifierProvider<IsShowCaptchaOnTap, bool>(
  IsShowCaptchaOnTap.new,
);
final isCopyCaptchaOnTapProvider = NotifierProvider<IsCopyCaptchaOnTap, bool>(
  IsCopyCaptchaOnTap.new,
);
