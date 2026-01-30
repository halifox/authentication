// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_transfer_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 处理数据传输操作（如备份和恢复）的控制器。

@ProviderFor(DataTransferController)
final dataTransferControllerProvider = DataTransferControllerProvider._();

/// 处理数据传输操作（如备份和恢复）的控制器。
final class DataTransferControllerProvider
    extends $NotifierProvider<DataTransferController, void> {
  /// 处理数据传输操作（如备份和恢复）的控制器。
  DataTransferControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dataTransferControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dataTransferControllerHash();

  @$internal
  @override
  DataTransferController create() => DataTransferController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$dataTransferControllerHash() =>
    r'0fc9206670e1a9f34cd674aa70f8d9a979bd2de1';

/// 处理数据传输操作（如备份和恢复）的控制器。

abstract class _$DataTransferController extends $Notifier<void> {
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
