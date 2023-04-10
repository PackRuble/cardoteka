import 'dart:ui' show Color;

import 'converter.dart';

/// The converter allows you to save the [Color] class to the database as [String].
class ColorConverter implements IConverter<Color, String> {
  const ColorConverter();

  @override
  Color fromDb(String value) => Color(int.parse(value));

  @override
  String toDb(Color color) => color.value.toString();
}
