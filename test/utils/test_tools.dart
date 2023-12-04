// @dart = 3.2

// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cardoteka/cardoteka.dart' show Card, DataType;
import 'package:cardoteka/src/extensions/data_type_ext.dart';
import 'package:flutter_test/flutter_test.dart' show test;

typedef AsyncCallback = Future<void> Function();

Future<void> testWith(
    Object description,
    dynamic Function() body, {
      dynamic Function()? setUp,
      dynamic Function()? tearDown,
    }) async {
  test(description, () async {
    await setUp?.call();
    await body.call();
    await tearDown?.call();
  });
}

String tekaReason(String message, Card card) => '''
$message
Broken on card: $card
''';

class TekaTool {
  TekaTool._();

  static bool isPrimitiveValue(Card card, {required bool elseNull}) {
    final Object? defaultValue = card.defaultValue;
    if (defaultValue == null) return elseNull;

    return card.type.isCorrectType(defaultValue);
  }

  static Object? getTestValueBasedOnDefaultValue(Card<Object?> card) {
    final Object? defaultValue = card.defaultValue;
    if (defaultValue == null) return null;
    return switch (card.type) {
      DataType.string => (defaultValue as String) + '_test',
      DataType.int => (defaultValue as int) * 2,
      DataType.double => (defaultValue as double) + 1.11111,
      DataType.bool => !(defaultValue as bool),
      DataType.stringList => (defaultValue as List<String>) + ['_test'],
    };
  }
}
