import 'dart:collection' show UnmodifiableListView;

import 'package:cardoteka/cardoteka.dart';
import 'package:flutter_test/flutter_test.dart';

import '../source/cardoteka_impl.dart';
import '../source/cards.dart';
import '../utils/test_tools.dart';

void main() {
  for (final config in allCardotekaConfigs) {
    late CardotekaAsyncTest cardoteka;
    Future<void> setUpAction() async {
      cardoteka = CardotekaAsyncTest(config: config, storage: MemoryStorage());
    }

    group('$config', () {
      testWith(
        '$CardotekaAsync.watcher--> watcher==null',
        setUp: setUpAction,
        () {
          final actualWatcher = cardoteka.watcher;

          expect(
            actualWatcher,
            isNull,
            reason:
                'Watcher must be null when $CardotekaAsyncTest without mix $Watcher',
          );
        },
      );

      testWith(
        '$CardotekaAsync.set-get-> saving and then retrieving the value',
        setUp: setUpAction,
        () async {
          for (final card in cardoteka.cards) {
            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            if (testValue == null) continue;
            await cardoteka.set(
              card,
              testValue,
            );

            // the [get] method should not receive cards that may have a nullable value
            if (card is! Card<Object>) continue;
            final getValue = await cardoteka.get(card);
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
        '$CardotekaAsync.set-get-> saving and then retrieving the value or null',
        setUp: setUpAction,
        () async {
          for (final card in cardoteka.cards) {
            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );
            if (testValue == null) continue;

            await cardoteka.set(
              card,
              testValue,
            );

            final getValue = await cardoteka.get(card);
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
        '$CardotekaAsync.set->containsCard->remove->containsCard',
        setUp: setUpAction,
        () async {
          for (final card in cardoteka.cards) {
            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            await cardoteka.set(card, testValue);
            bool isContains = await cardoteka.containsCard(card);

            expect(
              isContains,
              isTrue,
              reason: tekaReason(
                'The value must be contained after saving!',
                card,
              ),
            );

            await cardoteka.remove(card);

            isContains = await cardoteka.containsCard(card);
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
        '$CardotekaAsync.cards--> Taken from the configuration $CardotekaConfig',
        setUp: setUpAction,
        () {
          final actualCards = cardoteka.cards;

          expect(
            actualCards,
            equals(config.cards),
            reason: 'Lists must contain identical cards!',
          );

          expect(
            actualCards,
            isA<UnmodifiableListView<Card<Object?>>>(),
            reason: 'The list must be of type $UnmodifiableListView',
          );
        },
      );

      testWith(
        '$CardotekaAsync.set->getStoredCards->remove->getStoredCards.isEmpty '
        'Added value can be removed',
        setUp: setUpAction,
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

          final savedCards = (await cardoteka.getStoredCards()).toList();
          for (final card in beenSavedCards) {
            await cardoteka.remove(card);

            savedCards.remove(card);
            final resultGetCards = (await cardoteka.getStoredCards()).toList();
            expect(
              resultGetCards,
              unorderedEquals(savedCards),
              reason: 'The remaining cards must match those in $savedCards',
            );
          }

          final resultGetCards = await cardoteka.getStoredCards();
          expect(
            resultGetCards,
            isEmpty,
            reason: 'After deletion there should be no values in the storage!',
          );
        },
      );

      testWith(
        '$CardotekaAsync.set->getStoredCards->removeAll->getStoredCards '
        'Added values should be removed',
        setUp: setUpAction,
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

          var resultGetCards = (await cardoteka.getStoredCards()).toList();
          expect(
            resultGetCards,
            unorderedEquals(beenSavedCards),
            reason: 'All saved cards should be in $resultGetCards!',
          );

          await cardoteka.removeAll();

          resultGetCards = (await cardoteka.getStoredCards()).toList();
          expect(
            resultGetCards,
            isEmpty,
            reason: 'After deletion there should be no values in the storage!',
          );
        },
      );

      testWith(
        '$CardotekaAsync.set->getStoredEntries->removeAll->getStoredEntries'
        'The entities received are equal to those that were stored',
        setUp: setUpAction,
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

          var resultGetStoredEntries = await cardoteka.getStoredEntries();
          expect(
            resultGetStoredEntries,
            equals(beenSavedCards),
            reason: 'All saved cards should be in $resultGetStoredEntries!',
          );

          await cardoteka.removeAll();
          resultGetStoredEntries = await cardoteka.getStoredEntries();
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
