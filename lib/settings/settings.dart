const showCaptchaOnTapKey = 'is_show_captcha_on_tap';
const copyCaptchaOnTapKey = 'is_copy_captcha_on_tap';

const defaultSettings = <String, bool>{
  showCaptchaOnTapKey: false,
  copyCaptchaOnTapKey: false,
};

Map<String, bool> validateSettings(Object? value) {
  if (value is! Map || value.length != defaultSettings.length) {
    throw const FormatException('Invalid settings.');
  }
  final settings = <String, bool>{};
  for (final key in defaultSettings.keys) {
    final entry = value[key];
    if (entry is! bool) throw const FormatException('Invalid settings.');
    settings[key] = entry;
  }
  return settings;
}
