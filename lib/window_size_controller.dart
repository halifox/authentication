import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WindowSizeController extends GetxController with WidgetsBindingObserver {
  var screenWidth = 0.0.obs;
  var screenHeight = 0.0.obs;
  var contentWidth = 0.0.obs;
  var contentHeight = 0.0.obs;
  var maxCrossAxisExtent = 500.0;

  @override
  void onInit() {
    super.onInit();
    // 注册WidgetsBindingObserver
    WidgetsBinding.instance.addObserver(this);
    _updateWindowSize();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    // 窗口尺寸变化时更新状态
    _updateWindowSize();
  }

  void _updateWindowSize() {
    final size = WidgetsBinding.instance.window.physicalSize;
    var width = size.width;
    var height = size.height;
    screenWidth.value = width;
    screenHeight.value = height;

    if (width >= maxCrossAxisExtent * 3) {
      contentWidth.value = maxCrossAxisExtent * 3;
    } else if (width >= maxCrossAxisExtent * 2) {
      contentWidth.value = maxCrossAxisExtent * 2;
    } else if (width >= maxCrossAxisExtent * 1) {
      contentWidth.value = maxCrossAxisExtent * 1;
    } else {
      contentWidth.value = width;
    }
  }

  @override
  void onClose() {
    // 注销WidgetsBindingObserver
    WidgetsBinding.instance.removeObserver(this);
    super.onClose();
  }
}
