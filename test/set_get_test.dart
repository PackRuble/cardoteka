import 'dart:ui' show Color;

import 'package:cardoteka/cardoteka.dart';
import 'package:cardoteka/src/core.dart' show CardotekaUtilsForTest;
import 'package:flutter_test/flutter_test.dart';

import 'source/cards.dart';

class CardotekaImplTest extends Cardoteka with CardotekaUtilsForTest {
  CardotekaImplTest({required super.config});
}

Future<void> main() async {
  const newValuesByCard = <ForestCard<Object?>, Object>{
    ForestCard.keepAcacia: false,
    ForestCard.keepAcaciaWithNull: false,
    ForestCard.keepAcaciaWCK: false,
    ForestCard.ageBaobab: 50,
    ForestCard.ageBaobabWCK: 79,
    ForestCard.diameterTrunkBirch: 50.0,
    ForestCard.diameterTrunkBirchWCK: 31.999,
    ForestCard.habitatOak: 'Other regions',
    ForestCard.habitatOakWCK: 'Regions',
    ForestCard.namesLinden: [],
    ForestCard.namesLindenWCK: ['Linden1', 'Linden2'],
    ForestCard.currentColorSpruce: Color(0xFFAB6F00),
    ForestCard.currentColorSpruceWCK: Color(0x8CFF008C),
    ForestCard.lifetimeCedar: Duration(days: 600 * 365),
  };

  test(
    'The number of test value cards is the same as the number of all cards',
    () => expect(newValuesByCard, hasLength(ForestCard.values.length)),
  );

  late CardotekaImplTest cardoteka;
  setUp(() async {
    cardoteka = CardotekaImplTest(
      config: allCardConfigs.firstWhere((el) => el.name == '$ForestCard'),
    );
    cardoteka.setMockInitialValues({});
    await Cardoteka.init();
  });

  tearDown(() => cardoteka.deInit());

  test(
    "$Cardoteka.getOrNull-> Returns null if haven't saved values before",
    () {
      for (final card in ForestCard.values) {
        final result = cardoteka.getOrNull(card);
        expect(result, isNull);
      }
    },
  );

  test(
    "$Cardoteka.get-> Returns default value if haven't saved values before",
    () {
      for (final card in ForestCard.values) {
        // because [get] only accepts non-null cards.
        if (card == ForestCard.keepAcaciaWithNull) continue;

        final result = cardoteka.get(card as Card<Object>);
        expect(result, card.defaultValue);
      }
    },
  );

  test(
    "$Cardoteka.set->get&getOrNull-> Returns the set value",
    () async {
      for (final card in ForestCard.values) {
        final savedValue = newValuesByCard[card]!;
        final isSuccessSet = await cardoteka.set(card, savedValue);
        expect(isSuccessSet, isTrue);

        final resultOrNull = cardoteka.getOrNull(card);
        expect(resultOrNull, savedValue);

        // because [get] only accepts non-null cards.
        if (card == ForestCard.keepAcaciaWithNull) continue;
        final result = cardoteka.get(card as Card<Object>);
        expect(result, savedValue);
      }
    },
  );
}
