// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_account_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 添加账户页面的控制器，处理导航操作。

@ProviderFor(AddAccountController)
final addAccountControllerProvider = AddAccountControllerProvider._();

/// 添加账户页面的控制器，处理导航操作。
final class AddAccountControllerProvider
    extends $NotifierProvider<AddAccountController, void> {
  /// 添加账户页面的控制器，处理导航操作。
  AddAccountControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addAccountControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addAccountControllerHash();

  @$internal
  @override
  AddAccountController create() => AddAccountController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$addAccountControllerHash() =>
    r'265ee639e608bb490d221a38b9e0367bddcac990';

/// 添加账户页面的控制器，处理导航操作。

abstract class _$AddAccountController extends $Notifier<void> {
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
