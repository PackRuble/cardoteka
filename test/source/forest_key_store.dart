import 'dart:ui';

import 'package:cardoteka/cardoteka.dart';

const forestCardConfig = Config(
  name: 'ForestDb',
  converters: {
    ForestCard.currentColorSpruce: ColorConverter(),
    ForestCard.currentColorSpruceWCK: ColorConverter(),
  },
);

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
  currentColorSpruce<Color>(DataType.string, Color(0xFF00BFFD)),
  currentColorSpruceWCK<Color>(
      DataType.string, Color(0xFF37AB00), 'currentColorSpruceWCK_custom_key'),
  ;

  const ForestCard(this.type, this.defaultValue, [this._customKey]);

  @override
  final DataType type;

  @override
  final T defaultValue;

  final String? _customKey;

  @override
  String get key => _customKey ?? EnumName(this).name;
}
