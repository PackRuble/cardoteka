import 'dart:ui';

import 'package:reactive_db/reactive_db.dart';

/// WCK - with custom key.
enum ForestCard<T> implements ICard<T> {
  /// Are there such trees in the forest?
  keepAcacia<bool>(TypeData.bool, true),
  keepAcaciaWithNull<bool?>(TypeData.bool, true),
  keepAcaciaWCK<bool>(TypeData.bool, true, 'keepAcaciaWCK_custom_key'),

  /// Age of trees in ForestStore.
  ageBaobab<int>(TypeData.int, 100),
  ageBaobabWCK<int>(TypeData.int, 150, 'ageBaobabWCK_custom_key'),

  /// Average trunk diameter of birch trees in the forest in centimeters.
  diameterTrunkBirch<double>(TypeData.double, 55.7),
  diameterTrunkBirchWCK<double>(
      TypeData.double, 64.984, 'diameterTrunkBirchWCK_custom_key'),

  /// The habitat of the oak tree.
  habitatOak<String>(TypeData.string,
      'Northern Hemisphere regions with temperate, subtropical and tropical climates.'),
  habitatOakWCK<String>(TypeData.string, 'Northern Hemisphere regions',
      'habitatOakWCK_custom_key'),

  /// Some other names for the tree are "linden".
  namesLinden<List<String>>(TypeData.stringList, ['linden', 'lime tree']),
  namesLindenWCK<List<String>>(
      TypeData.stringList, [], 'namesLindenWCK_custom_key'),

  /// The current color of spruce needles.
  currentColorSpruce<Color>(TypeData.color, Color(0xFF00BFFD)),
  currentColorSpruceWCK<Color>(
      TypeData.color, Color(0xFF37AB00), 'currentColorSpruceWCK_custom_key'),
  ;

  const ForestCard(this.type, this.defaultValue, [this._customKey]);

  @override
  final TypeData type;

  @override
  final T defaultValue;

  final String? _customKey;

  @override
  String get key => _customKey ?? EnumName(this).name;

  @override
  CardConfig get config => CardConfig(name: 'ForestCard');
}

