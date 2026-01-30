// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 异步提供 [SharedPreferences] 实例。

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// 异步提供 [SharedPreferences] 实例。

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  /// 异步提供 [SharedPreferences] 实例。
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'd22b545aefe95500327f9dce52c645d746349271';

/// 提供 [SettingsRepository] 单例，封装了配置的存取逻辑。

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// 提供 [SettingsRepository] 单例，封装了配置的存取逻辑。

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SettingsRepository>,
          SettingsRepository,
          FutureOr<SettingsRepository>
        >
    with
        $FutureModifier<SettingsRepository>,
        $FutureProvider<SettingsRepository> {
  /// 提供 [SettingsRepository] 单例，封装了配置的存取逻辑。
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SettingsRepository> create(Ref ref) {
    return settingsRepository(ref);
  }
}

String _$settingsRepositoryHash() =>
    r'd54d25ded34b5653a1c965bd3cd0f1a904bd0116';

/// 管理生物识别解锁偏好的状态。

@ProviderFor(BiometricUnlock)
final biometricUnlockProvider = BiometricUnlockProvider._();

/// 管理生物识别解锁偏好的状态。
final class BiometricUnlockProvider
    extends $NotifierProvider<BiometricUnlock, bool> {
  /// 管理生物识别解锁偏好的状态。
  BiometricUnlockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'biometricUnlockProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$biometricUnlockHash();

  @$internal
  @override
  BiometricUnlock create() => BiometricUnlock();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$biometricUnlockHash() => r'bb530e10a866add2ac9be533e328314aae8301cd';

/// 管理生物识别解锁偏好的状态。

abstract class _$BiometricUnlock extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 管理“点击显示验证码”偏好的状态。

@ProviderFor(IsShowCaptchaOnTap)
final isShowCaptchaOnTapProvider = IsShowCaptchaOnTapProvider._();

/// 管理“点击显示验证码”偏好的状态。
final class IsShowCaptchaOnTapProvider
    extends $NotifierProvider<IsShowCaptchaOnTap, bool> {
  /// 管理“点击显示验证码”偏好的状态。
  IsShowCaptchaOnTapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isShowCaptchaOnTapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isShowCaptchaOnTapHash();

  @$internal
  @override
  IsShowCaptchaOnTap create() => IsShowCaptchaOnTap();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isShowCaptchaOnTapHash() =>
    r'4bcad857206b792b7a6a4f00280bc69a3d91cbb1';

/// 管理“点击显示验证码”偏好的状态。

abstract class _$IsShowCaptchaOnTap extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 管理“点击复制验证码”偏好的状态。

@ProviderFor(IsCopyCaptchaOnTap)
final isCopyCaptchaOnTapProvider = IsCopyCaptchaOnTapProvider._();

/// 管理“点击复制验证码”偏好的状态。
final class IsCopyCaptchaOnTapProvider
    extends $NotifierProvider<IsCopyCaptchaOnTap, bool> {
  /// 管理“点击复制验证码”偏好的状态。
  IsCopyCaptchaOnTapProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'isCopyCaptchaOnTapProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$isCopyCaptchaOnTapHash();

  @$internal
  @override
  IsCopyCaptchaOnTap create() => IsCopyCaptchaOnTap();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$isCopyCaptchaOnTapHash() =>
    r'28988ad47dbcb43f8b457a467299ddd5aa187a25';

/// 管理“点击复制验证码”偏好的状态。

abstract class _$IsCopyCaptchaOnTap extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
