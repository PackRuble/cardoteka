// ignore_for_file: discarded_futures

import 'dart:collection' show UnmodifiableListView;

import 'package:cardoteka/cardoteka.dart';
import 'package:cardoteka/src/core.dart' show CardotekaUtilsForTest;

import 'package:flutter_test/flutter_test.dart';

import '../source/cards.dart';
import '../utils/test_tools.dart';

class CardotekaTest extends Cardoteka with CardotekaUtilsForTest {
  CardotekaTest({required super.config});
}

void main() {
  for (final config in allCardotekaConfigs) {
    late CardotekaTest cardoteka;
    Future<void> setUpAction() async {
      cardoteka = CardotekaTest(config: config);
      cardoteka.setMockInitialValues({});
      await Cardoteka.init();
    }

    Future<void> tearDownAction() async {
      cardoteka.deInit();
    }

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

    group('$config', () {
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

            if (testValue == null) continue;
            final isSuccess = await cardoteka.set(
              card,
              testValue,
            );
            expect(
              isSuccess,
              isTrue,
              reason: tekaReason(
                'The value must be stored!',
                card,
              ),
            );

            // the [get] method should not receive cards that may have a nullable value
            if (card is! Card<Object>) continue;
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
        '$Cardoteka.set-getOrNull-> saving and then retrieving the value or null',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );
            if (testValue == null) continue;

            final isSuccess = await cardoteka.set(
              card,
              testValue,
            );
            expect(
              isSuccess,
              isTrue,
              reason: tekaReason(
                'The value must be stored!',
                card,
              ),
            );

            final getValue = cardoteka.getOrNull(card);
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
        '$Cardoteka.setOrNull-get-> saving and then retrieving the value',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            final isSuccess = await cardoteka.setOrNull(
              card,
              testValue,
            );

            if (testValue == null) {
              expect(
                isSuccess,
                isTrue,
                reason: tekaReason(
                  'A successful deletion should occur because it simulates the saving of a null-value',
                  card,
                ),
              );
            } else {
              expect(
                isSuccess,
                isTrue,
                reason: tekaReason('The value must be stored!', card),
              );
            }

            // the [get] method should not receive cards that may have a nullable value
            if (card is! Card<Object>) continue;
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
        '$Cardoteka.setOrNull-getOrNull-> saving and then retrieving the value or null',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            final isSuccess = await cardoteka.setOrNull(
              card,
              testValue,
            );
            if (testValue == null) {
              expect(
                isSuccess,
                isTrue,
                reason: tekaReason(
                  'A successful deletion should occur because it simulates the saving of a null-value',
                  card,
                ),
              );
            } else {
              expect(
                isSuccess,
                isTrue,
                reason: tekaReason('The value must be stored!', card),
              );
            }

            final getValue = cardoteka.getOrNull(card);
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
        '$Cardoteka.containsCard--> setOrNull-containsCard-remove-containsCard',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            final isSuccess = await cardoteka.setOrNull(
              card,
              testValue,
            );
            bool isContains = await cardoteka.containsCard(card);

            // means that [testValue] was null.
            // Therefore, the value is deleted from the store.
            if (testValue == null) {
              expect(
                isContains,
                isFalse,
                reason: tekaReason('The value should not be in storage!', card),
              );
              continue;
            } else {
              expect(
                isSuccess,
                isTrue,
                reason: tekaReason('The value must be stored!', card),
              );
            }

            expect(
              isContains,
              isTrue,
              reason: tekaReason(
                'The value must be contained after saving!',
                card,
              ),
            );

            final isSuccessRemove = await cardoteka.remove(card);
            expect(isSuccessRemove, isTrue);

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
            isA<UnmodifiableListView>(),
            reason: 'The list must be of type $UnmodifiableListView',
          );
        },
      );

      testWith(
        '$Cardoteka.isInitialized',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () {
          final actualInitialize = cardoteka.isInitialized;

          expect(
            actualInitialize,
            isTrue,
            reason: 'The storage must be initialized!',
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
            await cardoteka.set(card, testValue!);
          }

          final savedCards = cardoteka.getStoredCards().toList();
          for (final card in beenSavedCards) {
            final resultRemove = await cardoteka.remove(card);
            expect(
              resultRemove,
              isTrue,
              reason: 'The result of removing must be true',
            );

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
            final resultSet = await cardoteka.set(card, testValue!);
            expect(resultSet, isTrue, reason: tekaReason('set != false', card));
          }

          var resultGetCards = cardoteka.getStoredCards().toList();
          expect(
            resultGetCards,
            unorderedEquals(beenSavedCards),
            reason: 'All saved cards should be in $resultGetCards!',
          );

          final resultRemoveAll = await cardoteka.removeAll();
          expect(
            resultRemoveAll,
            isTrue,
            reason: 'All saved cards should be removed!',
          );

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
            final resultSet = await cardoteka.set(card, testValue);
            expect(resultSet, isTrue, reason: tekaReason('set != false', card));
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
