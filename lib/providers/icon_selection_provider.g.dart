// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'icon_selection_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 管理用于过滤图标的当前搜索查询。

@ProviderFor(IconSearchQuery)
final iconSearchQueryProvider = IconSearchQueryProvider._();

/// 管理用于过滤图标的当前搜索查询。
final class IconSearchQueryProvider
    extends $NotifierProvider<IconSearchQuery, String> {
  /// 管理用于过滤图标的当前搜索查询。
  IconSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'iconSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$iconSearchQueryHash();

  @$internal
  @override
  IconSearchQuery create() => IconSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$iconSearchQueryHash() => r'2f60be9c807a6102af262ddbdfb945ee7e5656f8';

/// 管理用于过滤图标的当前搜索查询。

abstract class _$IconSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// 从资源清单异步加载所有可用的图标文件名。

@ProviderFor(allIcons)
final allIconsProvider = AllIconsProvider._();

/// 从资源清单异步加载所有可用的图标文件名。

final class AllIconsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// 从资源清单异步加载所有可用的图标文件名。
  AllIconsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allIconsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allIconsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return allIcons(ref);
  }
}

String _$allIconsHash() => r'87384f865f0f44a59f7e2f604e03370ce3f6b63a';

/// 根据当前搜索查询过滤所有图标的列表。

@ProviderFor(filteredIcons)
final filteredIconsProvider = FilteredIconsProvider._();

/// 根据当前搜索查询过滤所有图标的列表。

final class FilteredIconsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// 根据当前搜索查询过滤所有图标的列表。
  FilteredIconsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredIconsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredIconsHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return filteredIcons(ref);
  }
}

String _$filteredIconsHash() => r'46e75f61cc386b90a476996ba90c860d717cb965';
