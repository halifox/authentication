import 'package:authentication/main.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as material;

void main() {
  test('preserves dynamic color roles when converting to Flutter', () {
    final scheme = material.ColorScheme.fromSeed(
      seedColor: const flutter.Color(0xff6750a4),
      brightness: flutter.Brightness.dark,
    );
    final converted = toFlutterColorScheme(scheme)!;
    expect(converted.primary, scheme.primary);
    expect(converted.surfaceContainer, scheme.surfaceContainer);
    expect(converted.onTertiaryFixedVariant, scheme.onTertiaryFixedVariant);
    expect(converted.brightness, scheme.brightness);
    expect(toFlutterColorScheme(null), isNull);
  });
}
