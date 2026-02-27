import 'dart:ui' show Color;

import '../src/converter.dart' show Converter;

/// Converter for class [Color].
///
/// Converts [Color] to [int] using [Color.toARGB32].
class ColorConverter implements Converter<Color, int> {
  const ColorConverter();

  @override
  Color from(int value) => Color(value);

  @override
  int to(Color object) => object.toARGB32();
}
