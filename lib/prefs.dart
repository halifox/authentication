import 'package:purity_auth/signal_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals_flutter/signals_flutter.dart';

class Prefs {
  final SharedPreferences sp;

  Prefs({required this.sp});

  late Signal<bool> biometricUnlock = SignalSharedPreferences<bool>('biometricUnlock', false, sp);
  late Signal<bool> isShowCaptchaOnTap = SignalSharedPreferences<bool>('isShowCaptchaOnTap', false, sp);
  late Signal<bool> isCopyCaptchaOnTap = SignalSharedPreferences<bool>('isCopyCaptchaOnTap', true, sp);

  void dispose() {}
}
