// ignore_for_file: discarded_futures

import 'package:cardoteka/cardoteka.dart';
import 'package:cardoteka/src/core.dart' show CardotekaUtilsForTest;
import 'package:flutter_test/flutter_test.dart';

import '../source/cards.dart';
import '../utils/test_tools.dart';

class CardotekaCRUD extends Cardoteka with CRUD, CardotekaUtilsForTest {
  CardotekaCRUD({required super.config});
}

void main() {
  for (final config in allCardotekaConfigs) {
    late CardotekaCRUD cardoteka;
    Future<void> setUpAction() async {
      cardoteka = CardotekaCRUD(config: config);
      cardoteka.setMockInitialValues({});
      await Cardoteka.init();
    }

    Future<void> tearDownAction() async {
      cardoteka.deInit();
    }

    group('$config', () {
      testWith(
        '$CRUD.read-> set-read',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            // CRUD can only work with non-nullable cards
            if (card is! Card<Object>) continue;

            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            await cardoteka.set(card, testValue!);

            final readValue = cardoteka.read(card);
            expect(
              readValue,
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
        '$Cardoteka.create-> create-read',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            // CRUD can only work with non-nullable cards
            if (card is! Card<Object>) continue;

            final isSuccess = await cardoteka.create(card);
            expect(
              isSuccess,
              isTrue,
              reason: tekaReason('The value must be stored!', card),
            );

            final readResult = cardoteka.read(card);
            expect(
              readResult,
              card.defaultValue,
              reason: tekaReason(
                'Should get the value that was saved earlier (defaultValue)!',
                card,
              ),
            );
          }
        },
      );

      testWith(
        '$Cardoteka.create-> create[value]-read',
        setUp: setUpAction,
        tearDown: tearDownAction,
            () async {
          for (final card in cardoteka.cards) {
            // CRUD can only work with non-nullable cards
            if (card is! Card<Object>) continue;

            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            final isSuccess = await cardoteka.create(card, testValue);
            expect(
              isSuccess,
              isTrue,
              reason: tekaReason('The value must be stored!', card),
            );

            final readValue = cardoteka.read(card);
            expect(
              readValue,
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
        '$Cardoteka.update-> create-update-read',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            // CRUD can only work with non-nullable cards
            if (card is! Card<Object>) continue;

            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            await cardoteka.create(card);

            final isSuccess = await cardoteka.update(card, testValue!);
            expect(
              isSuccess,
              isTrue,
              reason: tekaReason('The value must be stored!', card),
            );

            final readValue = cardoteka.read(card);
            expect(
              readValue,
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
        '$Cardoteka.update-> update-read',
        setUp: setUpAction,
        tearDown: tearDownAction,
            () async {
          for (final card in cardoteka.cards) {
            // CRUD can only work with non-nullable cards
            if (card is! Card<Object>) continue;

            final testValue = TekaTool.getTestValueBasedOnDefaultValue(
              card,
              config.converters,
            );

            final isSuccess = await cardoteka.update(card, testValue!);
            expect(
              isSuccess,
              isTrue,
              reason: tekaReason('The value must be stored!', card),
            );

            final readValue = cardoteka.read(card);
            expect(
              readValue,
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
        '$Cardoteka.delete-> create-{getCards-remove}-getCards.isEmpty '
        'Added value can be removed',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          final cards = [...config.cards]..shuffle();

          final beenSavedCards = <Card>[];
          for (final card in cards) {
            // CRUD can only work with non-nullable cards
            if (card is! Card<Object>) continue;

            beenSavedCards.add(card);
            await cardoteka.create(card);
          }

          final savedCards = cardoteka.getStoredCards().toList();
          for (final card in beenSavedCards) {
            final resultDelete = await cardoteka.delete(card);
            expect(
              resultDelete,
              isTrue,
              reason: 'The result of removing must be true!',
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
    });
  }
}
