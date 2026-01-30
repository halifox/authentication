// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_form_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 令牌表单页面的控制器，处理认证令牌的创建和更新。

@ProviderFor(TokenFormController)
final tokenFormControllerProvider = TokenFormControllerProvider._();

/// 令牌表单页面的控制器，处理认证令牌的创建和更新。
final class TokenFormControllerProvider
    extends $NotifierProvider<TokenFormController, void> {
  /// 令牌表单页面的控制器，处理认证令牌的创建和更新。
  TokenFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenFormControllerHash();

  @$internal
  @override
  TokenFormController create() => TokenFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$tokenFormControllerHash() =>
    r'd2113113f749e9b8d0c153345e1da0388ccfc540';

/// 令牌表单页面的控制器，处理认证令牌的创建和更新。

abstract class _$TokenFormController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
