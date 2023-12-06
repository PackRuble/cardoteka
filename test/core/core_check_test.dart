// ignore_for_file: prefer_final_locals, prefer_const_declarations, prefer_function_declarations_over_variables, unreachable_from_main

import 'package:cardoteka/src/card.dart';
import 'package:cardoteka/src/config.dart';
import 'package:cardoteka/src/utils/core_check.dart';
import 'package:flutter_test/flutter_test.dart';

import '../source/cards.dart';
import '../source/models.dart';

void main() {
  group('checkConfiguration()', () {
    test('general test of all checks at once', () {
      final config = CardConfig(
        name: 'PrimitiveTypeCards',
        cards: [...PrimitiveTypeCards.values]
          ..remove(PrimitiveTypeCards.card2DList),
        converters: const {
          PrimitiveTypeCards.cardTimeComplexNull: TimeConverter(),
          PrimitiveTypeCards.cardModelComplex: ModelConverter(),
          PrimitiveTypeCards.cardModelComplexNull: ModelConverter(),
        },
      );

      bool result = checkConfiguration(config);
      expect(result, isTrue);
    });
  });

  group('checkProvidedDataType()', () {
    test('Primitive types: all types in $DataType', () {
      bool result = checkProvidedDataType(primitiveCards, null);
      expect(result, isTrue);
    });
  });

  group('checkDuplicateKeys()', () {
    test("don't have duplicate keys", () {
      bool result = checkDuplicateKeys(primitiveCards);
      expect(result, isTrue);

      Map<Key, List<Card>> resultMap = getDuplicateKeys(primitiveCards);
      expect(resultMap, isEmpty);
    });

    test("have duplicate keys", () {
      final keys = primitiveCards;
      final duplicateCard = primitiveCards[2];
      Function resultFunc = () => checkDuplicateKeys([...keys, duplicateCard]);
      expect(resultFunc, throwsAssertionError);

      Map<Key, List<Card>> resultMap =
          getDuplicateKeys([...keys, duplicateCard]);
      expect(resultMap, isNotEmpty);
      expect(resultMap, hasLength(1));
      expect(resultMap, contains(duplicateCard.key));
      expect(resultMap[duplicateCard.key], isNotEmpty);
      expect(resultMap[duplicateCard.key], hasLength(2));
    });
  });

  group('isSimpleData()', () {
    test('value type is primitive $DataType', () {
      for (final card in primitiveCards) {
        expect(isSimpleData(card), isTrue);
      }
    });

    test('value type is nullable', () {
      for (final card in primitiveNullableCards) {
        expect(isSimpleData(card), isTrue);
      }
    });
  });

  group('checkConverterForComplexObject()', () {
    test('default value is Null', () {
      bool Function() resultFunc = () => checkConverterForComplexObject(
            primitiveCardsWithDefaultValueIsNull,
            const {},
          );

      expect(resultFunc(), isTrue);
    });

    test('have converters', () {
      bool Function() resultFunc = () => checkConverterForComplexObject(
            [
              PrimitiveTypeCards.cardTimeComplexNull,
              PrimitiveTypeCards.cardModelComplex,
              PrimitiveTypeCards.cardModelComplexNull,
            ],
            const {
              PrimitiveTypeCards.cardTimeComplexNull: TimeConverter(),
              PrimitiveTypeCards.cardModelComplex: ModelConverter(),
              PrimitiveTypeCards.cardModelComplexNull: ModelConverter(),
            },
          );

      expect(resultFunc(), isTrue);
    });

    test('primitive cards', () {
      bool Function() resultFunc = () => checkConverterForComplexObject(
            [...primitiveCards],
            null,
          );

      expect(resultFunc(), isTrue);
    });

    test('no converter for complex object', () {
      bool Function() resultFunc = () => checkConverterForComplexObject(
            [...primitiveComplexCards],
            null,
          );

      expect(resultFunc, throwsAssertionError);

      resultFunc = () => checkConverterForComplexObject(
            [PrimitiveTypeCards.card2DList],
            null,
          );

      expect(resultFunc, throwsAssertionError);
    });

    test("only primitive|with converters cards", () {
      bool Function() resultFunc = () => checkConverterForComplexObject(
            [...PrimitiveTypeCards.values]
              ..remove(PrimitiveTypeCards.card2DList),
            const {
              PrimitiveTypeCards.cardTimeComplexNull: TimeConverter(),
              PrimitiveTypeCards.cardModelComplex: ModelConverter(),
              PrimitiveTypeCards.cardModelComplexNull: ModelConverter(),
            },
          );

      expect(resultFunc(), isTrue);
    });
  });

  group('checkMatchingConverters()', () {
    test('converters empty|null', () {
      bool Function() resultFunc = () => checkMatchingConverters(null);
      expect(resultFunc(), isTrue);

      resultFunc = () => checkMatchingConverters(const {});
      expect(resultFunc(), isTrue);
    });

    test('card.defaultValue is null', () {
      bool Function() resultFunc = () => checkMatchingConverters(const {
            PrimitiveTypeCards.cardTimeComplexNull: TimeConverter(),
            PrimitiveTypeCards.cardModelComplexNull: ModelConverter(),
          });
      expect(resultFunc(), isTrue);
    });

    test('types match', () {
      bool Function() resultFunc = () => checkMatchingConverters(
            const {
              PrimitiveTypeCards.cardModelComplex: ModelConverter(),
            },
          );
      expect(resultFunc(), isTrue);
    });

    test("types don't match", () {
      bool Function() resultFunc = () => checkMatchingConverters(
            const {
              PrimitiveTypeCards.cardModelComplex: TimeConverter(),
            },
          );
      expect(resultFunc, throwsAssertionError);
    });
  });
}
