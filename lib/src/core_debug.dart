import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:reactive_db/reactive_db.dart';

/// Comprehensive verification of input data.
bool checkConfiguration(
    {required ConfigDB config, required List<ICard> cards}) {
  _checkKeys(cards);
  _checkConverterForComplexObject(cards, config.converters);
  _checkMatchingConverters(cards, config.converters);

  return true;
}

/// Check [ICard]'s keys for correctness.
bool _checkKeys<T>(List<ICard<T>> cards) {
  if (cards.isEmpty) return true;

  return _checkDuplicatesKeys(cards);
}

/// Check for a converter for complex objects.
bool _checkConverterForComplexObject(
  List<ICard> cards,
  Map<ICard<Object?>, IConverter<Object?, Object>>? converters,
) {
  // some checks are based on "runtimeType", which may not be accurate on the web.
  // todo: can be rewritten by checking for expected types
  if (!kIsWeb) {
    return true;
  }

  final supportedDataTypes = TypeData.values.map((e) => e.dartType);

  for (final card in cards) {
    if (card.defaultValue == null) continue;

    if (supportedDataTypes.contains(card.defaultValue.runtimeType)) {
      continue;
    } else if (converters?.containsKey(card) ?? false) {
      continue;
    } else {
      final availableConverters = StringBuffer();

      converters?.forEach((key, value) {
        availableConverters.writeln('$key: $value');
      });

      debugPrint('''
<$card> is a complex object. Check for a converter.
The following converters are found:
{
$availableConverters}
''');
      throw AssertionError();
    }
  }

  return true;
}

/// Checking for matching [ICard] and [CardConfig.converters].
///
/// It can fail in the web.
bool _checkMatchingConverters(
  List<ICard> cards,
  Map<ICard<Object?>, IConverter<Object?, Object>>? converters,
) {
  if (converters?.isEmpty ?? true) return true;

  for (final entry in converters!.entries) {
    final card = entry.key;
    final converter = entry.value;

    if (card.defaultValue is! Object) continue;

    if (card.type.dartType != converter.toDb(card.defaultValue).runtimeType) {
      debugPrint('''
The $card does not match the $converter.

Check if the converter types for the card match.
''');
      throw AssertionError();
    }
  }

  return true;
}

/// Check for duplicates [ICard.key].
bool _checkDuplicatesKeys(List<ICard> cards) {
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

/// Вернет true, усли
bool _isSimpleData(ICard card) {
  bool? result;

  if (card.defaultValue == null) result = true;

  switch (card.type) {
    case TypeData.bool:
      result = card.defaultValue is bool;
      break;
    case TypeData.int:
      result = card.defaultValue is int;
      break;
    case TypeData.double:
      result = card.defaultValue is double;
      break;
    case TypeData.string:
      result = card.defaultValue is String;
      break;
    case TypeData.stringList:
      result = card.defaultValue is List<String>;
      break;
    case TypeData.color:
      result = card.defaultValue is Color;
      break;
  }

  // if (result == false) {
  //   result = card.config.converters?.containsKey(card) ?? false;
  // }

  return result;
}

// ignore: avoid_positional_boolean_parameters
void checkInit(bool isInitialized) {
  assert(
    isInitialized,
    'The database was not initialized! Need to call [CardDb.init]',
  );
}
