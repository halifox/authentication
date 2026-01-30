// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 令牌列表页面的控制器，处理页面导航逻辑。

@ProviderFor(TokenListController)
final tokenListControllerProvider = TokenListControllerProvider._();

/// 令牌列表页面的控制器，处理页面导航逻辑。
final class TokenListControllerProvider
    extends $NotifierProvider<TokenListController, void> {
  /// 令牌列表页面的控制器，处理页面导航逻辑。
  TokenListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tokenListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tokenListControllerHash();

  @$internal
  @override
  TokenListController create() => TokenListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$tokenListControllerHash() =>
    r'78db882bf900477d296d71759f62a506d589099a';

/// 令牌列表页面的控制器，处理页面导航逻辑。

abstract class _$TokenListController extends $Notifier<void> {
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
