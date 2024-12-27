import 'package:shared_preferences/shared_preferences.dart';
import 'package:signals_flutter/signals_flutter.dart';

class SignalSharedPreferences<T> extends FlutterSignal<T> {
  EffectCleanup? disposeEffect;

  SignalSharedPreferences(String key, T defaultValue, SharedPreferences sp) : super(sp.get(key) as T? ?? defaultValue) {
    disposeEffect = effect(() {
      switch (super.value.runtimeType) {
        case const (bool):
          sp.setBool(key, super.value as bool);
        case const (double):
          sp.setDouble(key, super.value as double);
        case const (int):
          sp.setInt(key, super.value as int);
        case const (String):
          sp.setString(key, super.value as String);
        case const (List<String>):
          sp.setStringList(key, super.value as List<String>);
      }
    });
  }

  @override
  void dispose() {
    disposeEffect?.call();
    super.dispose();
  }
}
