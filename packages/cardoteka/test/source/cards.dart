import 'dart:ui' show Color;

import 'package:cardoteka/cardoteka.dart';
import 'package:cardoteka/cardoteka_flutter.dart';
import 'package:cardoteka/src/card.dart' show CardAbstract;

import 'models.dart';

mixin AdditionalTestValue<T> {
  abstract final T testValue;
}

abstract class CardTest<T> = CardAbstract<T> with AdditionalTestValue<T>;

const allCardotekaConfigs = [
  CardotekaConfig(
    cards: BarStoolParts.values,
  ),
  CardotekaConfig(
    cards: FishCard.values,
  ),
  CardotekaConfig(
    cards: PrimitiveTypeCards.values,
    converters: PrimitiveTypeCards.converters,
  ),
  CardotekaConfig(
    cards: SettingsCard.values,
  ),
  CardotekaConfig(
    cards: ForestCard.values,
    converters: ForestCard.converters,
  ),
];

///   ...                      ...
///   .-------------------------::
///   .-------------------------::
///    -:::  .:::::.  ::::::   -::.
///    ::::   :::::.  .:::::   -::.
///    ::::   -::::.  .:::::   ::::
///    .:::   ::::::   :::::.  ::::
///    .:::   .:::::   :::::.  .:::
///     -::.  .:::::   ::::::  .:::.
///     -:::   :::::.  .:::::  .-::.
///     ::::   :::::.  .:::::   -:::
///     ::::   ::::::  .-:::::..-:::
///     .:::--:::::::::::::::::---::
///     .-::::::.............   :-::
///      -:::                   :-::.
///      -:::                   .-:::
///      -:::                   .---:
///      :-:-.........:::::::::::---::::::::::::.
///      :=-------::-------------------------=---.
///      :=----:---------------------------------.
///      :===...:----:::........:---:        =---.
///      :===   :---:           .=--:        ----.
///      :===   .---:           .=--:        ----.
///      :===   .---:           .=--:        :---.
///      :---   .---:           .---:        :---.
///      :=--   .---:           .---:        :---.
///      :=--   .---:            ---.        :---.
///      :=--   .---:            ---.        .---.
///      :=-:   .---:            ---.        .---.
///      :=-:   .---:            ---.        .---:
///      :==:    ---:            ---         .---.
///      :==:    ---:  .......:::=--          ---.
///      -===-----------------:::=--          ---:
///      -==-::..---:            ==---:.      ---:
///      -=--.   ---:            ==--==---::::=--:
///      -=----. ----::::::-------------------=--:
///      -==.:-------------::::::---..     ..-=--:
///      -==   .----:            =--          ---:
///      -==     ---:            ---          :--:
///      -==     ---:                         :--:
///       ..     :--:                         :--:
///              :--:                         :--:
///              :--:                         .--:
///              :--:
///               :..
enum BarStoolParts<T extends Object> implements Card<T> {
  seat<int>(DataType.int, 1),
  backFrame<int>(DataType.int, 1),
  fontStretcher<int>(DataType.int, 1),
  sideStretcher<int>(DataType.int, 2),
  legL<int>(DataType.int, 1),
  legR<int>(DataType.int, 1),
  hexWrench<int>(DataType.int, 1),
  headCapBoltShort<int>(DataType.int, 4 + 1),
  headCapBoltLong<int>(DataType.int, 4 + 1),
  headCapBoltMiddle<int>(DataType.int, 4 + 1),
  woodScrewLong<int>(DataType.int, 2 + 1),
  woodScrewShort<int>(DataType.int, 8 + 2),
  springWasher<int>(DataType.int, 10 + 1),
  flatWasher<int>(DataType.int, 10 + 1),
  ;

  const BarStoolParts(this.dartType, this.defaultValue);

  @override
  final DataType dartType;

  @override
  final T defaultValue;

  @override
  String get key => name;
}

enum FishCard<T extends Object?> implements Card<T> {
  perch<int>(DataType.int, 2023),
  perchGhost<int?>(DataType.int, 2024),
  perchGhostNull<int?>(DataType.int, null),
  ;

  const FishCard(this.dartType, this.defaultValue);

  @override
  final DataType dartType;

  @override
  final T defaultValue;

  @override
  String get key => name;
}

const primitiveCards = <PrimitiveTypeCards>[
  PrimitiveTypeCards.cardBool,
  PrimitiveTypeCards.cardInt,
  PrimitiveTypeCards.cardDouble,
  PrimitiveTypeCards.cardString,
  PrimitiveTypeCards.cardStringListEmpty,
  PrimitiveTypeCards.cardStringList,
];
const primitiveNullableCards = <PrimitiveTypeCards>[
  PrimitiveTypeCards.cardBoolNull,
  PrimitiveTypeCards.cardBoolMayNull,
  PrimitiveTypeCards.cardStringListNull,
  PrimitiveTypeCards.cardStringListMayNull,
];

const primitiveCardsWithDefaultValueIsNull = <PrimitiveTypeCards>[
  PrimitiveTypeCards.cardBoolNull,
  PrimitiveTypeCards.cardStringListNull,
  PrimitiveTypeCards.cardTimeComplexNull,
  PrimitiveTypeCards.cardModelComplexNull,
];

const primitiveComplexCards = <PrimitiveTypeCards>[
  PrimitiveTypeCards.card2DList,
  PrimitiveTypeCards.cardTimeComplexNull,
  PrimitiveTypeCards.cardModelComplex,
  PrimitiveTypeCards.cardModelComplexNull,
];

enum PrimitiveTypeCards<T extends Object?> implements Card<T> {
  cardBool<bool>(DataType.bool, true),
  cardInt<int>(DataType.int, 0),
  cardDouble<double>(DataType.double, 0.0),
  cardString<String>(DataType.string, ''),

  /// The type of list elements can only be [String].
  cardStringListEmpty<List<String>>(DataType.list, []),
  cardStringList<List<String>>(DataType.list, ['']),

  /// Nullable cards
  cardBoolNull<bool?>(DataType.bool, null),
  cardBoolMayNull<bool?>(DataType.bool, true),
  cardStringListNull<List<String>?>(DataType.list, null),
  cardStringListMayNull<List<String>?>(DataType.list, ['']),

  /// Complex [defaultValue] in cards
  card2DList<List<List<dynamic>>>(DataType.string, [[], []]),
  cardTimeComplexNull<Time?>(DataType.int, null),
  cardModelComplex<Model>(DataType.string, Model()),
  cardModelComplexNull<Model?>(DataType.string, null);

  const PrimitiveTypeCards(this.dartType, this.defaultValue);

  @override
  final DataType dartType;

  @override
  final T defaultValue;

  @override
  String get key => name;

  static const converters = <Card, Converter>{
    cardTimeComplexNull: TimeConverter(),
    cardModelComplex: ModelConverter(),
    cardModelComplexNull: ModelConverter(),
    card2DList: List2DConverterStub(),
  };
}

enum SettingsCard implements Card<Object> {
  homeIndex(DataType.int, 1),
  relativePathSettings(DataType.string, r'%MYDOCUMENTS%\app_settings\'),
  aspectLayout(DataType.double, 0.32),
  listCodes(DataType.list, ['error', '403', '2030']),
  ;

  const SettingsCard(this.dartType, this.defaultValue);

  @override
  final DataType dartType;

  @override
  final Object defaultValue;

  @override
  String get key => name;
}

/// WCK - with custom key.
enum ForestCard<T> implements CardTest<T> {
  /// Are there such trees in the forest?
  keepAcacia<bool>(DataType.bool, true, false),
  keepAcaciaWithNull<bool?>(DataType.bool, true, false),
  keepAcaciaWithNullDefault<bool?>(DataType.bool, null, true),
  keepAcaciaWCK<bool>(DataType.bool, true, false, 'keepAcaciaWCK_custom_key'),

  /// Age of trees in ForestStore.
  ageBaobab<int>(DataType.int, 100, 98),
  ageBaobabWCK<int>(DataType.int, 150, 120, 'ageBaobabWCK_custom_key'),

  /// Average trunk diameter of birch trees in the forest in centimeters.
  diameterTrunkBirch<double>(DataType.double, 55.7, 60.1111),
  diameterTrunkBirchWCK<double>(
      DataType.double, 64.984, 44.02, 'diameterTrunkBirchWCK_custom_key'),

  /// The habitat of the oak tree.
  habitatOak<String>(
    DataType.string,
    'Northern Hemisphere regions with temperate, subtropical and tropical climates.',
    'tested: unknown location for habitatOak',
  ),
  habitatOakWCK<String>(
    DataType.string,
    'Northern Hemisphere regions',
    'tested: unknown location for habitatOakWCK',
    'habitatOakWCK_custom_key',
  ),

  /// Some other names for the tree are "linden".
  namesLinden<List<String>>(
    DataType.list,
    ['linden', 'lime tree'],
    ['tree'],
  ),
  namesLindenWCK<List<String>>(
    DataType.list,
    [],
    ['tree', 'tree_new', 'tree_meow'],
    'namesLindenWCK_custom_key',
  ),

  /// The current color of spruce needles.
  currentColorSpruce<Color>(
    DataType.int,
    Color(0xFF00BFFD),
    Color(0xFF9855FD),
  ),
  currentColorSpruceWCK<Color>(
    DataType.int,
    Color(0xFF37AB00),
    Color(0xFFAB0000),
    'currentColorSpruceWCK_custom_key',
  ),
  lifetimeCedar<Duration>(
    DataType.int,
    Duration(days: 500 * 365),
    Duration(days: 499 * 365),
  ),
  ;

  const ForestCard(
    this.dartType,
    this.defaultValue,
    this.testValue, [
    this._customKey,
  ]);

  @override
  final DataType dartType;

  @override
  final T defaultValue;

  @override
  final T testValue;

  final String? _customKey;

  @override
  String get key => _customKey ?? EnumName(this).name;

  static const converters = <Card, Converter>{
    currentColorSpruce: ColorConverter(),
    currentColorSpruceWCK: ColorConverter(),
    lifetimeCedar: Converters.durationAsInt,
  };
}
