// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_code_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// 处理二维码扫描和图片上传功能的控制器。

@ProviderFor(QrCodeController)
final qrCodeControllerProvider = QrCodeControllerProvider._();

/// 处理二维码扫描和图片上传功能的控制器。
final class QrCodeControllerProvider
    extends $NotifierProvider<QrCodeController, void> {
  /// 处理二维码扫描和图片上传功能的控制器。
  QrCodeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'qrCodeControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$qrCodeControllerHash();

  @$internal
  @override
  QrCodeController create() => QrCodeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$qrCodeControllerHash() => r'0349e70bddb319748fc061a64742e8fe2caa5150';

/// 处理二维码扫描和图片上传功能的控制器。

abstract class _$QrCodeController extends $Notifier<void> {
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
