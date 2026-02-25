import 'dart:collection' show UnmodifiableListView;

import 'package:cardoteka/cardoteka.dart';
import 'package:flutter_test/flutter_test.dart';

import '../source/cardoteka_impl.dart';
import '../source/cards.dart';
import '../utils/test_tools.dart';

void main() {
  late CardotekaTest cardoteka;

  Future<void> tearDownAction() async {}

  // todo(22.02.2026, @PackRuble): test by types with complex object
  // todo(22.02.2026, @PackRuble): test sync|async storage with incorrect cardoteka

  test(
    '$Cardoteka.get->getOrDefault check static types',
    () {
      cardoteka = CardotekaTest(
        // ignore config
        config: const CardotekaConfig(cards: []),
        storage: MemoryStorage(),
      );

      const card = SingleCard<int>('age', 56, DataType.int);
      const cardNull = SingleCard<int?>('age', null, DataType.int);
      const cardDefaultNonNull = SingleCard<int?>('age', 45, DataType.int);

      final result = cardoteka.get(card);
      final resultOrNull1 = cardoteka.get(cardNull);
      final resultOrNull2 = cardoteka.get(cardDefaultNonNull);
      expect(result, isA<int?>());
      expect(resultOrNull1, isA<int?>());
      expect(resultOrNull2, isA<int?>());

      final resultDefault = cardoteka.getOrDefault(card);
      final resultOrNullDefault = cardoteka.getOrDefault(cardNull);
      expect(resultDefault, isA<int>());
      expect(resultOrNullDefault, isA<int?>());

      final
          // is logical, since the type is derived from the specified
          int? resultOrDefault = cardoteka.getOrDefault(cardDefaultNonNull);
      expect(resultOrDefault, isA<int>());
    },
  );

  for (final config in allCardotekaConfigs) {
    Future<void> setUpAction() async {
      cardoteka = CardotekaTest(config: config, storage: MemoryStorage());
    }

    group('$config', () {
      testWith(
        '$Cardoteka.watcher--> watcher==null',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () {
          final actualWatcher = cardoteka.watcher;

          expect(
            actualWatcher,
            isNull,
            reason:
                'Watcher must be null when $CardotekaTest without mix $Watcher',
          );
        },
      );

      testWith(
        '$Cardoteka.set-get-> saving and then retrieving the value',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            await cardoteka.set(card, testValue);

            final getValue = cardoteka.get(card);
            expect(
              getValue,
              testValue,
              reason: tekaReason(
                'Should get the value that was saved earlier!',
                card,
              ),
            );
          }
        },
      );

      testWith(
        '$Cardoteka.set-getOrDefault-> saving and then retrieving the value or defaultValue',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            await cardoteka.set(card, testValue);

            final getValue = cardoteka.getOrDefault(card);
            expect(
              getValue,
              testValue,
              reason: tekaReason(
                'Should get the value that was saved earlier or default value!',
                card,
              ),
            );
          }
        },
      );

      testWith(
        '$Cardoteka.set-get-> saving and then retrieving the value or null',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            await cardoteka.set(
              card,
              testValue,
            );

            final getValue = cardoteka.get(card);
            expect(
              getValue,
              testValue,
              reason: tekaReason(
                'Should get the value that was saved earlier!',
                card,
              ),
            );
          }
        },
      );

      testWith(
        "$Cardoteka.getOrDefault-> Returns default value if haven't saved values before",
        setUp: setUpAction,
        tearDown: tearDownAction,
        () {
          for (final card in cardoteka.cards) {
            final result = cardoteka.getOrDefault(card);
            expect(result, card.defaultValue);
          }
        },
      );

      testWith(
        '$Cardoteka.containsCard--> set-containsCard-remove-containsCard',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            await cardoteka.set(
              card,
              testValue,
            );
            bool isContains = cardoteka.containsCard(card);

            expect(
              isContains,
              isTrue,
              reason: tekaReason(
                'The value must be contained after saving!',
                card,
              ),
            );

            await cardoteka.remove(card);

            isContains = cardoteka.containsCard(card);
            expect(
              isContains,
              isFalse,
              reason: tekaReason(
                'The value has been removed from storage, so should be missing!',
                card,
              ),
            );
          }
        },
      );

      testWith(
        '$Cardoteka.cards--> Taken from the configuration $CardotekaConfig',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () {
          final actualCards = cardoteka.cards;

          expect(
            actualCards,
            equals(config.cards),
            reason: 'Lists must contain identical cards!',
          );

          expect(
            actualCards,
            isA<UnmodifiableListView<dynamic>>(),
            reason: 'The list must be of type $UnmodifiableListView',
          );
        },
      );

      testWith(
        '$Cardoteka.remove-> set-{getCards-remove}-getCards.isEmpty '
        'Added value can be removed',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          final cards = [...config.cards]..shuffle();

          final beenSavedCards = <Card>[];
          for (final card in cards) {
            if (TekaTool.isNonPrimitiveDefaultValue(card, ifNull: true)) {
              continue;
            }

            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            beenSavedCards.add(card);
            await cardoteka.set(card, testValue);
          }

          final savedCards = cardoteka.getStoredCards().toList();
          for (final card in beenSavedCards) {
            await cardoteka.remove(card);

            savedCards.remove(card);
            final resultGetCards = cardoteka.getStoredCards().toList();
            expect(
              resultGetCards,
              unorderedEquals(savedCards),
              reason: 'The remaining cards must match those in $savedCards',
            );
          }

          final resultGetCards = cardoteka.getStoredCards();
          expect(
            resultGetCards,
            isEmpty,
            reason: 'After deletion there should be no values in the storage!',
          );
        },
      );

      testWith(
        '$Cardoteka.removeAll-> set-getCards-removeAll-getCards '
        'Added values should be removed',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          final cards = [...config.cards]..shuffle();

          final beenSavedCards = <Card>[];
          for (final card in cards) {
            if (TekaTool.isNonPrimitiveDefaultValue(card, ifNull: true)) {
              continue;
            }

            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            beenSavedCards.add(card);
            await cardoteka.set(card, testValue);
          }

          var resultGetCards = cardoteka.getStoredCards().toList();
          expect(
            resultGetCards,
            unorderedEquals(beenSavedCards),
            reason: 'All saved cards should be in $resultGetCards!',
          );

          await cardoteka.removeAll();

          resultGetCards = cardoteka.getStoredCards().toList();
          expect(
            resultGetCards,
            isEmpty,
            reason: 'After deletion there should be no values in the storage!',
          );
        },
      );

      testWith(
        '$Cardoteka.getStoredEntries-> set-getStoredEntries-removeAll-getStoredEntries '
        'The entities received are equal to those that were stored',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          final cards = [...config.cards]..shuffle();

          final beenSavedCards = <Card, Object>{};
          for (final card in cards) {
            if (TekaTool.isNonPrimitiveDefaultValue(card, ifNull: true)) {
              continue;
            }

            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            beenSavedCards[card] = testValue!;
            await cardoteka.set(card, testValue);
          }

          var resultGetStoredEntries = cardoteka.getStoredEntries();
          expect(
            resultGetStoredEntries,
            equals(beenSavedCards),
            reason: 'All saved cards should be in $resultGetStoredEntries!',
          );

          await cardoteka.removeAll();
          resultGetStoredEntries = cardoteka.getStoredEntries();
          expect(
            resultGetStoredEntries,
            isEmpty,
            reason:
                'After deleting this $resultGetStoredEntries should be empty!',
          );
        },
      );
    });
  }
}
