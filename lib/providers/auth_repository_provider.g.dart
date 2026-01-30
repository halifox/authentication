// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_repository_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 提供 [AuthRepository] 的单例实例，确保数据库访问。

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// 提供 [AuthRepository] 的单例实例，确保数据库访问。

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// 提供 [AuthRepository] 的单例实例，确保数据库访问。
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'9ddd26b7a9d56954ed56f4acaf57f9d4ba97bfab';

/// 流提供者，用于监听仓库中的认证条目列表。

@ProviderFor(authEntryList)
final authEntryListProvider = AuthEntryListProvider._();

/// 流提供者，用于监听仓库中的认证条目列表。

final class AuthEntryListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<AuthEntry>>,
          List<AuthEntry>,
          Stream<List<AuthEntry>>
        >
    with $FutureModifier<List<AuthEntry>>, $StreamProvider<List<AuthEntry>> {
  /// 流提供者，用于监听仓库中的认证条目列表。
  AuthEntryListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authEntryListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authEntryListHash();

  @$internal
  @override
  $StreamProviderElement<List<AuthEntry>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<AuthEntry>> create(Ref ref) {
    return authEntryList(ref);
  }
}

String _$authEntryListHash() => r'2e294c0a7adfaf7d3f18f94e45502e3a3092a9cc';
