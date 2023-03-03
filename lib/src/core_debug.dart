import 'dart:ui';

import 'i_card.dart';

/// Check [ICard]'s keys for correctness.
void debugCheckKeys(List<ICard> keys) {
  assert(
    () {
      for (final key in keys) {
        assert(
          key.defaultValue != null && key.defaultValue is Object,
          'For key: $key - [defaultValue] must be null, instead of ${key.defaultValue}',
        );
      }
      return true;
    }.call(),
  );
}

/// Identify if a custom converter is provided, if one is needed.
void debugCheckProvidedCustomConverter(ICard card) {
  assert(
    () {
      bool result;
      switch (card.type) {
        case TypeData.bool:
          result = card.defaultValue is bool?;
          break;
        case TypeData.int:
          result = card.defaultValue is int?;
          break;
        case TypeData.double:
          result = card.defaultValue is double?;
          break;
        case TypeData.string:
          result = card.defaultValue is String?;
          break;
        case TypeData.stringList:
          result = card.defaultValue is List<String>?;
          break;
        case TypeData.color:
          result = card.defaultValue is Color?;
          break;
      }

      if (result == false) {
        result = card.config.converters?.containsKey(card) ?? false;
      }

      return result;
    }.call(),
    'To provide custom converter for your complex object.',
  );
}

// ignore: avoid_positional_boolean_parameters
void debugCheckInit(bool isInitialized) {
  assert(
    () {
      if (!isInitialized) {
        return false;
      }
      return true;
    }.call(),
    'The database was not initialized! Need to call [CardDb.init]',
  );
}
