// todo: add Enum

import 'package:flutter/material.dart';

class Converter {
  Converter._();

  static String colorToString(Color color) => color.value.toString();

  static Color colorFromString(String value) => Color(int.parse(value));
}

