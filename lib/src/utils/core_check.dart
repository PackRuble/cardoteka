import 'package:meta/meta.dart';

import '../card.dart';
import '../config.dart';
import '../converter.dart';
import '../extensions/data_type_ext.dart';

/// This implementation allows \n characters to be used.
@internal
class AssertionErrorImpl extends AssertionError {
  AssertionErrorImpl(super.message);

  @override
  String toString() => 'Assertion failed: $message';
}

/// TODO:
/// 1. Translate everything into custom errors.
/// 2. Do separate class Assertion error (test-friendly)

@internal
typedef CardToConverters = Map<Card<Object?>, Converter<Object?, Object>>;

/// Comprehensive verification of input data.
///
/// Used only in development mode in `assert`. May throw an error [AssertionErrorImpl].
@internal
bool checkConfiguration(CardConfig config) {
  checkKeys(config.cards);
  checkConverterForComplexObject(config.cards, config.converters);
  checkMatchingConverters(config.converters);
  checkProvidedDataType(config.cards, config.converters);

  return true;
}

/// Check if the specified type [DataType] matches the provided type [Card.defaultValue].
/// We do this based on the type of default value provided. If there is
/// a converter for the given card, we skip the check.
///
/// Note:
/// - can't check when value is nullable type
/// - in web can't check when value is [double] or [int]
@internal
bool checkProvidedDataType<T>(
  List<Card<T>> cards,
  CardToConverters? converters,
) {
  for (final card in cards) {
    final Object? value = card.defaultValue;

    // we cannot determine the type for sure if the value is null.
    if (value == null) continue;

    /// we will check it in [_checkMatchingConverters].
    if (converters?.containsKey(card) ?? false) continue;

    if (!card.type.isCorrectType(value)) {
      throw AssertionErrorImpl('''
The provided type [${card.type}] does not match the type of the [$card.defaultValue]:
->Expected type: ${card.type.getDartType()}
->Actual type: ${card.defaultValue.runtimeType}
''');
    }
  }

  return true;
}

/// Check [Card]'s keys for correctness.
@internal
bool checkKeys<T>(List<Card<T>> cards) {
  if (cards.isEmpty) return true;

  checkDuplicateKeys(cards);
  return true;
}

/// Check for a converter for complex objects.
///
/// We cannot check [Null] values (for all platforms).
@internal
bool checkConverterForComplexObject(
  List<Card<Object?>> cards,
  CardToConverters? converters,
) {
  for (final card in cards) {
    if (card.defaultValue == null) continue;

    if (isSimpleData(card)) {
      continue;
    } else if (converters?.containsKey(card) ?? false) {
      continue;
    } else {
      final message = StringBuffer('''
[$card] has a complex [Card.defaultValue]. Check for a converter.
''');
      if (converters?.isEmpty ?? true) {
        message.write('No converters were found: $converters');
      } else {
        message.writeln('The following converters are found:');
        message.writeln('{');
        converters?.forEach((key, value) {
          message.writeln(' $key: $value,');
        });
        message.writeln('}');
      }
      throw AssertionErrorImpl(message);
    }
  }

  return true;
}

/// Checking for matching [Card] and [CardConfig.converters].
///
/// Note: We cannot guarantee verification of the [double] and [int] types in the web.
/// Also, we cannot check [Null] values (for all platforms).
@internal
bool checkMatchingConverters(
  CardToConverters? converters,
) {
  if (converters?.isEmpty ?? true) return true;

  for (final entry in converters!.entries) {
    final card = entry.key;
    final converter = entry.value;

    final Object? value = card.defaultValue;

    // we cannot determine the type for sure if the value is null.
    if (value == null) continue;

    // todo: warning messages to the console if the map is of type int or double + web

    final excepted = card.type.getDartType();
    Type? afterConverted;
    try {
      afterConverted = converter.to(value).runtimeType;

      if (excepted != afterConverted) {
        throw '';
      }
    } catch (error) {
      throw AssertionErrorImpl('''
The [$card] does not match the [$converter]:
->Type expected: [$excepted]
->Type after conversion: [${afterConverted ?? error}]
Check if the converter types for the card match.
''');
    }
  }

  return true;
}

/// The type for the [Card.key] field.
@internal
typedef Key = String;

/// Check for duplicates [Card.key].
@internal
bool checkDuplicateKeys(List<Card> cards) {
  final Map<Key, List<Card>> duplicateKeys = getDuplicateKeys(cards);
  if (duplicateKeys.isNotEmpty) {
    final bufferDuplicateKeys = StringBuffer();
    duplicateKeys
        .forEach((key, list) => bufferDuplicateKeys.writeln(' $key : $list'));

    throw AssertionErrorImpl(
        'Each [${duplicateKeys.values.first.first}] must be unique key. Your cards contain'
        ' the following [key] duplicates:\n'
        '[\n'
        '$bufferDuplicateKeys'
        ']');
  }

  return true;
}

/// Returns a duplicates [Card.key].
@internal
Map<Key, List<Card>> getDuplicateKeys(List<Card> cards) {
  final duplicateKeys = <Key, List<Card>>{};

  for (final card in cards) {
    duplicateKeys.update(
      card.key,
      (list) => [...list, card],
      ifAbsent: () => [card],
    );
  }

  duplicateKeys.removeWhere((key, list) => list.length == 1);

  return duplicateKeys;
}

/// Returns true if the type is valid (one of [DataType]).
///
/// Note: in the web double can be equal to int.
@internal
bool isSimpleData(Card<Object?> card) {
  final Object? value = card.defaultValue;

  // we cannot determine the type for sure if the value is null.
  if (value == null) return true;

  return card.type.isCorrectType(value);
}
