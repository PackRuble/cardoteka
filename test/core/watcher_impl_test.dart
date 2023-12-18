// @dart = 3.2

// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:math';

import 'package:cardoteka/cardoteka.dart';
import 'package:cardoteka/src/core.dart' show CardotekaUtilsForTest;
import 'package:cardoteka/src/mixin/watcher_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import '../source/cards.dart';
import '../utils/test_tools.dart';

class CardotekaTest extends Cardoteka
    with WatcherImpl, WatcherImplDebug, CardotekaUtilsForTest, AccessToSP {
  CardotekaTest({required super.config});
}

Future<void> main() async {
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

    group('$WatcherImpl with config: $config', () {
      testWith(
        '$WatcherImpl.attach -> Checking operations that call a callback',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            if (TekaTool.isNonPrimitiveDefaultValue(card, ifNull: false)) {
              continue;
            }

            final Object? defaultValue = card.defaultValue;
            final Object? newValue =
                TekaTool.getTestValueBasedOnDefaultValue(card);
            final actionForResultInCallback =
                <(AsyncCallback action, Object? expectedValue)>[
              if (newValue != null)
                (() async => cardoteka.set(card, newValue), newValue),
              (() async => cardoteka.remove(card), defaultValue),
              (() async => cardoteka.setOrNull(card, newValue), newValue),
              (() async => cardoteka.removeAll(), defaultValue),
            ];
            int counter = 0;

            late final void Function() detacher;
            cardoteka.attach(
              card,
              (cbValue) => expect(
                cbValue,
                actionForResultInCallback[counter++].$2,
                reason: tekaReason(
                  'The callback should return a new value as soon as it changes in the store'
                  '$actionForResultInCallback, when count is $counter',
                  card,
                ),
              ),
              onRemove: () => actionForResultInCallback[counter++].$2,
              detacher: (onDetach) => detacher = onDetach,
            );

            await Future.wait(
                actionForResultInCallback.map((e) => e.$1.call()));

            expect(
              actionForResultInCallback,
              hasLength(counter),
              reason: tekaReason(
                'All operations must trigger the callback!\n'
                'watchers: ${cardoteka.getWatchers()}',
                card,
              ),
            );
            detacher.call();
          }
        },
      );

      testWith(
        '$WatcherImpl.attach -> What does attach return when storage is empty?',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            final value = cardoteka.attach(card, (_) {}, detacher: (_) {});
            expect(
              value,
              card.defaultValue,
              reason: tekaReason(
                'Should always return to default value!',
                card,
              ),
            );
          }
        },
      );

      testWith(
        '$WatcherImpl.attach -> What does attach return when storage contains value?',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            if (TekaTool.isNonPrimitiveDefaultValue(card, ifNull: false)) {
              continue;
            }

            final testedValue = TekaTool.getTestValueBasedOnDefaultValue(card);
            await cardoteka.setOrNull(
              card,
              TekaTool.getTestValueBasedOnDefaultValue(card),
            );

            final value = cardoteka.attach(card, (_) {}, detacher: (_) {});
            expect(
              value,
              testedValue,
              reason: tekaReason(
                'Should return a value that is contained in the storage!',
                card,
              ),
            );
          }
        },
      );

      testWith(
        '$WatcherImpl.attach -> Registering several callbacks',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            final count = 1 + Random().nextInt(10);
            for (var i = 0; i < count; ++i) {
              cardoteka.attach(card, (_) {}, detacher: (_) {});
            }

            expect(
              cardoteka.watchersDebug[card],
              hasLength(count),
              reason: tekaReason(
                'The number of callbacks must be equal to the number of attachments!',
                card,
              ),
            );
          }
        },
      );

      testWith(
        '$WatcherImpl.attach -> detacher: one card, many callbacks',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            final detachers = <int, void Function()>{};
            final count = 1 + Random().nextInt(10);

            for (var i = 0; i < count; ++i) {
              cardoteka.attach(card, (_) {}, detacher: (onDetach) {
                detachers[i] = onDetach;
              });
            }

            for (var i = 0; i < count; ++i) {
              expect(
                cardoteka.watchersDebug[card],
                hasLength(count - i),
                reason: tekaReason(
                  'The number of callbacks in [detachers] must match the number of attachments!\n'
                  'detachers: $detachers \n'
                  'watchers: ${cardoteka.getWatchers()}',
                  card,
                ),
              );

              detachers[i]?.call();
            }
          }
        },
      );

      testWith(
        '$WatcherImpl.attach -> detacher: many cards, many callbacks',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          final detachers = <Card, List<void Function()>>{};
          for (final card in cardoteka.cards) {
            final count = 1 + Random().nextInt(10);

            for (var i = 0; i < count; ++i) {
              cardoteka.attach(card, (_) {}, detacher: (onDetach) {
                detachers[card] ??= [];
                detachers[card]!.add(onDetach);
              });
            }
          }

          for (final MapEntry(key: card, value: callbacks)
              in detachers.entries) {
            for (final (index, cb) in callbacks.indexed) {
              expect(
                cardoteka.watchersDebug[card],
                hasLength(callbacks.length - index),
                reason: tekaReason(
                  'The number of callbacks in [detachers] must match the number of attachments!\n'
                  'detachers: $detachers \n'
                  'watchers: ${cardoteka.getWatchers()}',
                  card,
                ),
              );

              cb.call();
            }
          }
        },
      );

      testWith(
        '$WatcherImpl.attach -> fireImmediately=false + onRemove',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            bool callBackCall = false;
            bool onRemoveCall = false;
            cardoteka.attach(
              card,
              (_) => callBackCall = true,
              onRemove: () => onRemoveCall = true,
              detacher: (_) {},
              fireImmediately: false,
            );

            expect(
              callBackCall && onRemoveCall,
              isFalse,
              reason: tekaReason(
                'when fireImmediately=false callback should NOT be called immediately!',
                card,
              ),
            );
          }
        },
      );

      testWith(
        '$WatcherImpl.attach -> fireImmediately=true + onRemove',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            bool callBackCall = false;
            bool onRemoveCall = false;
            cardoteka.attach(
              card,
              (_) => callBackCall = true,
              onRemove: () => onRemoveCall = true,
              detacher: (_) {},
              fireImmediately: true,
            );

            if (card.defaultValue == null) {
              expect(
                onRemoveCall,
                isTrue,
                reason: tekaReason(
                  'when fireImmediately=true callback must be called immediately!',
                  card,
                ),
              );
            } else {
              expect(
                callBackCall,
                isTrue,
                reason: tekaReason(
                  'when fireImmediately=true callback must be called immediately!',
                  card,
                ),
              );
            }
          }
        },
      );

      testWith(
        '$WatcherImpl.attach -> $Cardoteka.setOrNull-remove-$WatcherImpl.onRemove',
        setUp: setUpAction,
        tearDown: tearDownAction,
        () async {
          for (final card in cardoteka.cards) {
            bool callbackCall = false;
            bool onRemoveCall = false;
            cardoteka.attach(
              card,
              (_) => callbackCall = true,
              onRemove: () => onRemoveCall = true,
              detacher: (_) {},
              fireImmediately: false,
            );

            final testedValue = TekaTool.getTestValueBasedOnDefaultValue(
                card, config.converters);
            await cardoteka.setOrNull(card, testedValue);
            if (testedValue == null) {
              expect(
                onRemoveCall,
                isTrue,
                reason: tekaReason('onRemove should be called!', card),
              );
              expect(
                callbackCall,
                isFalse,
                reason: tekaReason(
                    "callbackCall should not have been called!", card),
              );
            } else {
              expect(
                onRemoveCall,
                isFalse,
                reason:
                    tekaReason('onRemove should not have been called!', card),
              );
              expect(
                callbackCall,
                isTrue,
                reason: tekaReason("callbackCall should be called!", card),
              );
            }

            callbackCall = false;
            onRemoveCall = false;
            await cardoteka.remove(card);
            expect(
              onRemoveCall,
              isTrue,
              reason: tekaReason('onRemove should be called!', card),
            );
            expect(
              callbackCall,
              isFalse,
              reason:
                  tekaReason("callbackCall should not have been called!", card),
            );
          }
        },
      );
    });
  }
}
