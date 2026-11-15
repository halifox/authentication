import 'package:flutter/foundation.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

// Standalone widget trees and unsupported renderers use the shader-free path.
bool glassShadersReady = false;

GlassQuality get appGlassQuality =>
    !kIsWeb && glassShadersReady ? GlassQuality.standard : GlassQuality.minimal;
