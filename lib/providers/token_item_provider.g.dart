// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'token_item_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 单个令牌项的控制器，管理其 UI 状态和操作。

@ProviderFor(TokenItem)
final tokenItemProvider = TokenItemFamily._();

/// 单个令牌项的控制器，管理其 UI 状态和操作。
final class TokenItemProvider
    extends $NotifierProvider<TokenItem, TokenItemState> {
  /// 单个令牌项的控制器，管理其 UI 状态和操作。
  TokenItemProvider._({
    required TokenItemFamily super.from,
    required int super.argument,
  }) : super(
         retry: null,
         name: r'tokenItemProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$tokenItemHash();

  @override
  String toString() {
    return r'tokenItemProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TokenItem create() => TokenItem();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TokenItemState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TokenItemState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TokenItemProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$tokenItemHash() => r'e514d92985871528449b4f0ad821229be2535722';

/// 单个令牌项的控制器，管理其 UI 状态和操作。

final class TokenItemFamily extends $Family
    with
        $ClassFamilyOverride<
          TokenItem,
          TokenItemState,
          TokenItemState,
          TokenItemState,
          int
        > {
  TokenItemFamily._()
    : super(
        retry: null,
        name: r'tokenItemProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// 单个令牌项的控制器，管理其 UI 状态和操作。

  TokenItemProvider call(int id) =>
      TokenItemProvider._(argument: id, from: this);

  @override
  String toString() => r'tokenItemProvider';
}

/// 单个令牌项的控制器，管理其 UI 状态和操作。

abstract class _$TokenItem extends $Notifier<TokenItemState> {
  late final _$args = ref.$arg as int;
  int get id => _$args;

  TokenItemState build(int id);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<TokenItemState, TokenItemState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TokenItemState, TokenItemState>,
              TokenItemState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}
