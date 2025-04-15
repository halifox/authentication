import 'package:auth/auth_repository.dart';
import 'package:auth/signal_shared_preferences.dart';
import 'package:signals_flutter/signals_flutter.dart';

class Prefs {
  static late Signal<bool> biometricUnlock = SignalSharedPreferences<bool>('biometricUnlock', false, sp);
  static late Signal<bool> isShowCaptchaOnTap = SignalSharedPreferences<bool>('isShowCaptchaOnTap', false, sp);
  static late Signal<bool> isCopyCaptchaOnTap = SignalSharedPreferences<bool>('isCopyCaptchaOnTap', true, sp);
}
