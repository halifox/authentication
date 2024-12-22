import 'package:flutter/material.dart';

mixin WindowSizeStateMixin<T extends StatefulWidget> on State<T> implements WidgetsBindingObserver {
  final maxCrossAxisExtent = 500.0;
  var contentWidth = 500.0;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    didChangeMetrics();
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final size = WidgetsBinding.instance.window.physicalSize;
    final width = size.width;
    final height = size.height;

    setState(() {
      if (width >= maxCrossAxisExtent * 3) {
        contentWidth = maxCrossAxisExtent * 3;
      } else if (width >= maxCrossAxisExtent * 2) {
        contentWidth = maxCrossAxisExtent * 2;
      } else if (width >= maxCrossAxisExtent * 1) {
        contentWidth = maxCrossAxisExtent * 1;
      } else {
        contentWidth = width;
      }
    });
  }
}
