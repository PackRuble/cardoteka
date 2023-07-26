// ignore_for_file: prefer_final_locals, prefer_const_declarations, prefer_function_declarations_over_variables, unreachable_from_main

import 'package:cardoteka/src/card.dart';
import 'package:cardoteka/src/config.dart';
import 'package:cardoteka/src/converter.dart';
import 'package:cardoteka/src/utils/core_check.dart';
import 'package:flutter_test/flutter_test.dart';

class Model {
  const Model();
}

class ModelConverter implements Converter<Model, String> {
  const ModelConverter();

  @override
  Model from(_) => const Model();

  @override
  String to(_) => '';
}

class Time {
  const Time(this.value);

  final DateTime value;

  factory Time.fromJson(Map<String, dynamic> json) =>
      Time(DateTime.parse(json['value'] as String));

  Map<String, dynamic> toJson() => {'value': value.toIso8601String()};
}

class TimeConverter implements Converter<Time, int> {
  const TimeConverter();

  @override
  Time from(int data) => Time(DateTime.fromMillisecondsSinceEpoch(data));

  @override
  int to(Time object) => object.value.millisecondsSinceEpoch;
}

enum PrimitiveTypeCards<T extends Object?> implements Card<T> {
  cardBool<bool>(DataType.bool, true),
  cardInt<int>(DataType.int, 0),
  cardDouble<double>(DataType.double, 0.0),
  cardString<String>(DataType.string, ''),

  /// The type of list elements can only be [String].
  cardStringListEmpty<List<String>>(DataType.stringList, []),
  cardStringList<List<String>>(DataType.stringList, ['']),

  /// Nullable cards
  cardBoolNull<bool?>(DataType.bool, null),
  cardBoolMayNull<bool?>(DataType.bool, true),
  cardStringListNull<List<String>?>(DataType.stringList, null),
  cardStringListMayNull<List<String>?>(DataType.stringList, ['']),

  /// Complex [defaultValue] in cards
  card2DList<List<List>>(DataType.string, [[], []]),
  cardTimeComplexNull<Time?>(DataType.int, null),
  cardModelComplex<Model>(DataType.string, Model()),
  cardModelComplexNull<Model?>(DataType.string, null);

  const PrimitiveTypeCards(this.type, this.defaultValue);

  @override
  final DataType type;

  @override
  final T defaultValue;

  @override
  String get key => name;

  static CardConfig get config => const CardConfig(
        name: 'PrimitiveTypeCards',
        cards: PrimitiveTypeCards.values,
        converters: {},
      );
}

const primitiveCards = [
  PrimitiveTypeCards.cardBool,
  PrimitiveTypeCards.cardInt,
  PrimitiveTypeCards.cardDouble,
  PrimitiveTypeCards.cardString,
  PrimitiveTypeCards.cardStringListEmpty,
  PrimitiveTypeCards.cardStringList,
];
const primitiveNullableCards = [
  PrimitiveTypeCards.cardBoolNull,
  PrimitiveTypeCards.cardBoolMayNull,
  PrimitiveTypeCards.cardStringListNull,
  PrimitiveTypeCards.cardStringListMayNull,
];

const cardsWithDefaultValueIsNull = [
  PrimitiveTypeCards.cardBoolNull,
  PrimitiveTypeCards.cardStringListNull,
  PrimitiveTypeCards.cardTimeComplexNull,
  PrimitiveTypeCards.cardModelComplexNull,
];

const complexCards = [
  PrimitiveTypeCards.card2DList,
  PrimitiveTypeCards.cardTimeComplexNull,
  PrimitiveTypeCards.cardModelComplex,
  PrimitiveTypeCards.cardModelComplexNull,
];

void main() {
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
            cardsWithDefaultValueIsNull,
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
            [...complexCards],
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
      expect(resultFunc(), throwsAssertionError);
    });
  });
}
