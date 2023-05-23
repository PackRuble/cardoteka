import 'package:flutter/foundation.dart';

import '../card.dart';
import '../config.dart';
import '../converter.dart';
import '../extensions/data_type_ext.dart';

// TODO:
// 1. Translate everything into custom errors.

/// Comprehensive verification of input data.
bool checkConfiguration(Config config) {
  _checkKeys(config.cards);
  _checkProvidedDataType(config.cards, config.converters);
  _checkConverterForComplexObject(config.cards, config.converters);
  _checkMatchingConverters(config.cards, config.converters);

  return true;
}

/// Check if the specified type [DataType] matches the provided type [Card.defaultValue].
///
/// Note:
/// - can't check when value is nullable type
/// - in web can't check when value is [double] or [int]
bool _checkProvidedDataType<T>(
  List<Card<T>> cards,
  Map<Card<Object?>, Converter<Object?, Object>>? converters,
) {
  for (final card in cards) {
    final Object? value = card.defaultValue;

    // we cannot determine the type for sure if the value is null.
    if (value == null) continue;

    /// we will check it in [_checkMatchingConverters].
    if (converters?.containsKey(card) ?? false) continue;

    if (!card.type.isCorrectType(value)) {
      debugPrint('''
The provided type <${card.type}> does not match the type of the $card.defaultValue: <${card.defaultValue.runtimeType}>.
Expected type: <${card.type.getDartType()}>
''');
      throw AssertionError();
    }
  }

  return true;
}

/// Check [Card]'s keys for correctness.
bool _checkKeys<T>(List<Card<T>> cards) {
  if (cards.isEmpty) return true;

  return _checkDuplicatesKeys(cards);
}

/// Check for a converter for complex objects.
///
/// We cannot check [Null] values (for all platforms).
bool _checkConverterForComplexObject(
  List<Card<Object?>> cards,
  Map<Card<Object?>, Converter<Object?, Object>>? converters,
) {
  for (final card in cards) {
    if (card.defaultValue == null) continue;

    if (_isSimpleData(card)) {
      continue;
    } else if (converters?.containsKey(card) ?? false) {
      continue;
    } else {
      final availableConverters = StringBuffer();

      converters?.forEach((key, value) {
        availableConverters.writeln('$key: $value');
      });

      throw AssertionError('''
<$card> is a complex object. Check for a converter.
The following converters are found:
{
$availableConverters}
''');
    }
  }

  return true;
}

/// Checking for matching [Card] and [CardConfig.converters].
///
/// Note: We cannot guarantee verification of the [double] and [int] types in the web.
/// Also, we cannot check [Null] values (for all platforms).
bool _checkMatchingConverters(
  List<Card<Object?>> cards,
  Map<Card<Object?>, Converter<Object?, Object>>? converters,
) {
  if (converters?.isEmpty ?? true) return true;

  for (final entry in converters!.entries) {
    final card = entry.key;
    final converter = entry.value;

    final Object? value = card.defaultValue;

    // we cannot determine the type for sure if the value is null.
    if (value == null) continue;

    final excepted = card.type.getDartType();
    final afterConverted = converter.to(value).runtimeType;

    if (excepted != afterConverted) {
      throw AssertionError('''
The $card does not match the $converter.
  Type expected: <$excepted>
  Type after conversion: <$afterConverted>
Check if the converter types for the card match.
''');
    }
  }

  return true;
}

/// Check for duplicates [Card.key].
bool _checkDuplicatesKeys(List<Card> cards) {
  List<String>? duplicateKeys;

  final List<String> keys = cards.map((e) => e.key).toList();

  if (keys.toSet().length != keys.length) {
    for (final k in keys.toSet()) {
      keys.remove(k);
    }

    duplicateKeys = keys;

    throw AssertionError(
        'Each <${cards.first.runtimeType}.key> must be unique. Your cards contain the following <key> duplicates: \n'
        '$duplicateKeys');
  }

  return true;
}

/// Returns true if the type is valid (one of [DataType]).
///
/// Note: in the web double can be equal to int.
bool _isSimpleData(Card<Object?> card) {
  final Object? value = card.defaultValue;

  // we cannot determine the type for sure if the value is null.
  if (value == null) return true;

  return card.type.isCorrectType(value);
}

// ignore: avoid_positional_boolean_parameters
void checkInit(bool isInitialized, String nameStorage) {
  assert(
    isInitialized,
    'The storage `$nameStorage` was not initialized! '
    'Need to call `await Cardoteka.init()`',
  );
}
