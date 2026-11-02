const showCaptchaOnTapKey = 'is_show_captcha_on_tap';
const copyCaptchaOnTapKey = 'is_copy_captcha_on_tap';
const showAccountNameKey = 'show_account_name';

const defaultSettings = <String, bool>{
  showCaptchaOnTapKey: false,
  copyCaptchaOnTapKey: false,
  showAccountNameKey: true,
};

Map<String, bool> validateSettings(Object? value) {
  if (value is! Map ||
      value.keys.any((key) => !defaultSettings.containsKey(key)) ||
      !value.containsKey(showCaptchaOnTapKey) ||
      !value.containsKey(copyCaptchaOnTapKey)) {
    throw const FormatException('Invalid settings.');
  }
  final settings = <String, bool>{};
  for (final key in defaultSettings.keys) {
    if (!value.containsKey(key)) continue;
    final entry = value[key];
    if (entry is! bool) throw const FormatException('Invalid settings.');
    settings[key] = entry;
  }
  return settings;
}
