import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:reactive_db/reactive_db.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'source/forest_key_store.dart';

class ForestDb extends CardDb {
  ForestDb({required super.cards});
}

void main() {
  SharedPreferences.setMockInitialValues({});

  test('Simple getting/setting by Enum.key', () async {
    // we may to call ForestDb() - it's the same thing
    final db = ForestDb(cards: ForestCard.values);

    await db.init();

    // Simple reading by key
    for (final key in ForestCard.values) {
      // if (key == ForestCard.keepAcaciaWithNull) {
      //   db.getOrNull(key);
      //   continue;
      // }
      db.getOrNull(key);
    }

    final newSetup = <ForestCard<Object>, Object>{
      ForestCard.keepAcacia: false,
      ForestCard.keepAcaciaWCK: false,
      ForestCard.ageBaobab: 50,
      ForestCard.ageBaobabWCK: 79,
      ForestCard.diameterTrunkBirch: 50.0,
      ForestCard.diameterTrunkBirchWCK: 31.999,
      ForestCard.habitatOak: 'Other regions',
      ForestCard.habitatOakWCK: 'Regions',
      ForestCard.namesLinden: [],
      ForestCard.namesLindenWCK: ['Linden1', 'Linden2'],
      ForestCard.currentColorSpruce: const Color(0xFFAB6F00),
      ForestCard.currentColorSpruceWCK: const Color(0x8CFF008C),
    };

    // Simple setting by key
    for (final entry in newSetup.entries) {
      await db.set(entry.key, entry.value);
    }

    // We get the values to compare with [newSetup]:
    for (final entry in newSetup.entries) {
      expect(
        db.get(entry.key),
        entry.value,
      );
    }

    expect(db.get(ForestCard.keepAcacia), isNotNull);
    expect(db.get(ForestCard.keepAcacia), isA<bool>());
    expect(db.getOrNull(ForestCard.keepAcacia), isA<bool?>());

    expect(db.getOrNull(ForestCard.keepAcaciaWithNull), isA<bool?>());

    await db.set(ForestCard.keepAcaciaWithNull, false);
    expect(db.getOrNull(ForestCard.keepAcaciaWithNull), isNotNull);
  });
}
