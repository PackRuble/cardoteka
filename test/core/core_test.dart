import 'package:cardoteka/cardoteka.dart';
import 'package:cardoteka/src/core.dart' show CardotekaUtilsForTest;

import 'package:flutter_test/flutter_test.dart';

import '../source/cards.dart';
import '../utils/test_tools.dart';

class CardotekaTest extends Cardoteka with CardotekaUtilsForTest {
  CardotekaTest({required super.config});
}

void main() {
  for (final config in allCardConfigs) {
    late CardotekaTest cardoteka;
    Future<void> setUpAction() async {
      cardoteka = CardotekaTest(config: config);
      cardoteka.setMockInitialValues({});
      await Cardoteka.init();
    }

    Future<void> tearDownAction() async {
      cardoteka.deInit();
    }

    group('config: $config', () {
      // ignore: discarded_futures
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

      // ignore: discarded_futures
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

      // ignore: discarded_futures
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
            if (isSuccess == null) {
              expect(
                testValue,
                isNull,
                reason: tekaReason('The stored value must also be null', card),
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

      // ignore: discarded_futures
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
            if (isSuccess == null) {
              expect(
                testValue,
                isNull,
                reason: tekaReason('The stored value must also be null', card),
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
    });
  }
}
