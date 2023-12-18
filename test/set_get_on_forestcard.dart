import 'package:cardoteka/cardoteka.dart';
import 'package:cardoteka/src/core.dart' show CardotekaUtilsForTest;
import 'package:flutter_test/flutter_test.dart';

import 'source/cards.dart';

class CardotekaImplTest extends Cardoteka with CardotekaUtilsForTest {
  CardotekaImplTest({required super.config});
}

Future<void> main() async {
  late CardotekaImplTest cardoteka;
  setUp(() async {
    cardoteka = CardotekaImplTest(
      config: allCardotekaConfigs.firstWhere((el) => el.name == '$ForestCard'),
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
        if (card == ForestCard.keepAcaciaWithNull ||
            card == ForestCard.keepAcaciaWithNullDefault) continue;

        final result = cardoteka.get(card as Card<Object>);
        expect(result, card.defaultValue);
      }
    },
  );

  test(
    "$Cardoteka.set->get&getOrNull-> Returns the set value",
    () async {
      for (final card in ForestCard.values) {
        final isSuccessSet =
            await cardoteka.set(card, card.testValue as Object);
        expect(isSuccessSet, isTrue);

        final resultOrNull = cardoteka.getOrNull(card);
        expect(resultOrNull, card.testValue);

        // because [get] only accepts non-null cards.
        if (card == ForestCard.keepAcaciaWithNull ||
            card == ForestCard.keepAcaciaWithNullDefault) continue;
        final result = cardoteka.get(card as Card<Object>);
        expect(result, card.testValue);
      }
    },
  );
}
