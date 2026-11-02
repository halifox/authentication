import 'package:authentication/settings/settings.dart';
import 'package:authentication/storage/database_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final settingsProvider = StreamProvider<Map<String, bool>>(
  (ref) => ref.watch(appDatabaseProvider).watchSettings(),
);

final integerSettingsProvider = StreamProvider<Map<String, int>>(
  (ref) => ref.watch(appDatabaseProvider).watchIntegerSettings(),
);

final isShowCaptchaOnTapProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider).value?[showCaptchaOnTapKey] ?? true,
);

final isCopyCaptchaOnTapProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider).value?[copyCaptchaOnTapKey] ?? false,
);

final showAccountNameProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider).value?[showAccountNameKey] ?? true,
);

class SettingsOperations extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> updateInteger(String key, int value) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(appDatabaseProvider).setIntegerSetting(key, value),
    );
  }

  Future<void> update(String key, bool value) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(appDatabaseProvider).setSetting(key, value),
    );
  }
}

final settingsOperationsProvider =
    NotifierProvider<SettingsOperations, AsyncValue<void>>(
      SettingsOperations.new,
    );
