import 'dart:ui' show Color;

import 'package:cardoteka/cardoteka.dart';

final allCards = [
  CardConfig(
    name: '$BarStoolParts',
    cards: BarStoolParts.values,
  ),
  CardConfig(
    name: '$FishCard',
    cards: FishCard.values,
  ),
  CardConfig(
    name: '$ForestCard',
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

  const BarStoolParts(this.type, this.defaultValue);

  @override
  final DataType type;

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

  const FishCard(this.type, this.defaultValue);

  @override
  final DataType type;

  @override
  final T defaultValue;

  @override
  String get key => name;
}

/// WCK - with custom key.
enum ForestCard<T> implements Card<T> {
  /// Are there such trees in the forest?
  keepAcacia<bool>(DataType.bool, true),
  keepAcaciaWithNull<bool?>(DataType.bool, true),
  keepAcaciaWCK<bool>(DataType.bool, true, 'keepAcaciaWCK_custom_key'),

  /// Age of trees in ForestStore.
  ageBaobab<int>(DataType.int, 100),
  ageBaobabWCK<int>(DataType.int, 150, 'ageBaobabWCK_custom_key'),

  /// Average trunk diameter of birch trees in the forest in centimeters.
  diameterTrunkBirch<double>(DataType.double, 55.7),
  diameterTrunkBirchWCK<double>(
      DataType.double, 64.984, 'diameterTrunkBirchWCK_custom_key'),

  /// The habitat of the oak tree.
  habitatOak<String>(DataType.string,
      'Northern Hemisphere regions with temperate, subtropical and tropical climates.'),
  habitatOakWCK<String>(DataType.string, 'Northern Hemisphere regions',
      'habitatOakWCK_custom_key'),

  /// Some other names for the tree are "linden".
  namesLinden<List<String>>(DataType.stringList, ['linden', 'lime tree']),
  namesLindenWCK<List<String>>(
      DataType.stringList, [], 'namesLindenWCK_custom_key'),

  /// The current color of spruce needles.
  currentColorSpruce<Color>(DataType.int, Color(0xFF00BFFD)),
  currentColorSpruceWCK<Color>(
      DataType.int, Color(0xFF37AB00), 'currentColorSpruceWCK_custom_key'),
  mySleepDuration<Duration>(DataType.int, Duration(hours: 7)),
  ;

  const ForestCard(this.type, this.defaultValue, [this._customKey]);

  @override
  final DataType type;

  @override
  final T defaultValue;

  final String? _customKey;

  @override
  String get key => _customKey ?? EnumName(this).name;

  static const converters = {
    currentColorSpruce: Converters.colorAsInt,
    currentColorSpruceWCK: Converters.colorAsInt,
    mySleepDuration: Converters.durationAsInt,
  };
}
