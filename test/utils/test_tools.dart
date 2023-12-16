// @dart = 3.2

// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cardoteka/cardoteka.dart' show Card, Converter, DataType;
import 'package:cardoteka/src/extensions/data_type_ext.dart';
import 'package:flutter_test/flutter_test.dart' show test;
import 'package:meta/meta.dart' show isTest;

typedef AsyncCallback = Future<void> Function();

@isTest
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

  static bool isPrimitiveDefaultValue(Card card, {required bool ifNull}) {
    final Object? defaultValue = card.defaultValue;
    if (defaultValue == null) return ifNull;

    return card.type.isCorrectType(defaultValue);
  }

  static bool isNonPrimitiveDefaultValue(Card card, {required bool ifNull}) {
    final Object? defaultValue = card.defaultValue;
    if (defaultValue == null) return ifNull;

    return !card.type.isCorrectType(defaultValue);
  }

  static Object? getTestValueBasedOnDefaultValue(
    Card<Object?> card, [
    Map<Card, Converter>? converters,
  ]) {
    final Object? defaultValue = card.defaultValue;
    if (defaultValue == null) return null;

    final converter = converters?[card];
    final value = converter?.to(defaultValue) ?? defaultValue;

    final testValue =  switch (card.type) {
      DataType.string => (value as String) + '_test',
      DataType.int => (value as int) * 2,
      DataType.double => (value as double) + 1.11111,
      DataType.bool => !(value as bool),
      DataType.stringList => (value as List<String>) + ['_test'],
    };

    return converter?.from(testValue) ?? testValue;
  }
}
