const showCaptchaOnTapKey = 'is_show_captcha_on_tap';
const copyCaptchaOnTapKey = 'is_copy_captcha_on_tap';
const showAccountNameKey = 'show_account_name';
const advanceHotpOnCopyKey = 'advance_hotp_on_copy';
const sortLockedKey = 'sort_locked';

const defaultSettings = <String, bool>{
  showCaptchaOnTapKey: false,
  copyCaptchaOnTapKey: false,
  showAccountNameKey: true,
  advanceHotpOnCopyKey: false,
  sortLockedKey: true,
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

const hideCodeAfterKey = 'hide_code_after_seconds';
const hideCodeDelayOptions = <int>[0, 5, 10, 30, 60];
const sortModeKey = 'account_sort_mode';
const sortModeOptions = <int>[0, 1, 2, 3, 4];
const defaultIntegerSettings = <String, int>{
  hideCodeAfterKey: 0,
  sortModeKey: 0,
};

void validateIntegerSetting(String key, Object? value) {
  final allowed = switch (key) {
    hideCodeAfterKey => hideCodeDelayOptions,
    sortModeKey => sortModeOptions,
    _ => throw const FormatException('Unknown integer setting.'),
  };
  if (value is! int || !allowed.contains(value)) {
    throw const FormatException('Invalid integer setting.');
  }
}

Map<String, int> validateIntegerSettings(Object? value) {
  if (value is! Map ||
      !value.containsKey(hideCodeAfterKey) ||
      value.keys.any(
        (key) => key is! String || !defaultIntegerSettings.containsKey(key),
      )) {
    throw const FormatException('Invalid integer settings.');
  }
  final result = <String, int>{};
  for (final key in defaultIntegerSettings.keys) {
    if (!value.containsKey(key)) continue;
    validateIntegerSetting(key, value[key]);
    result[key] = value[key] as int;
  }
  return result;
}
