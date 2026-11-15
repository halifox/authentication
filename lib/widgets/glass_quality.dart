import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

// Standalone widget trees and unsupported renderers use the shader-free path.
bool glassShadersReady = false;

GlassQuality get appGlassQuality {
  if (!glassShadersReady || kIsWeb) {
    return GlassQuality.minimal;
  }
  return ui.ImageFilter.isShaderFilterSupported
      ? GlassQuality.premium
      : GlassQuality.standard;
}
