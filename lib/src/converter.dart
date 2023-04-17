import 'dart:ui' show Color;

/// Use to transform a complex model for work to database.
abstract class Converter<V extends Object?, T extends Object> {
  const Converter();

  V from(T value);
  T to(V object);

  @override
  String toString() => 'from: $V, to: $T';
}

/// The converter allows you to save the [Color] class to the database as [String].
class ColorConverter implements Converter<Color, String> {
  const ColorConverter();

  @override
  Color from(String value) => Color(int.parse(value));

  @override
  String to(Color color) => color.value.toString();
}
