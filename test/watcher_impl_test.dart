// @dart = 3.2

// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:math';

import 'package:cardoteka/cardoteka.dart';
import 'package:cardoteka/src/core.dart' show CardotekaUtilsForTest;
import 'package:cardoteka/src/extensions/data_type_ext.dart';
import 'package:cardoteka/src/mixin/watcher_impl.dart';
import 'package:flutter_test/flutter_test.dart';

import 'source/forest_key_store.dart';

enum FishCard<T extends Object?> implements Card<T> {
  perch<int>(DataType.int, 2023),
  perchGhost<int?>(DataType.int, 2024),
  perchGhostNull<int?>(DataType.int, null),
  ;

  const FishCard(this.type, this.defaultValue);

  @override
  final DataType type;

  @override
  final T defaultValue;

  @override
  String get key => name;
}

final cardsCollections = [
  CardConfig(
    name: '$FishCard',
    cards: FishCard.values,
  ),
  CardConfig(
    name: '$ForestCard',
    cards: ForestCard.values,
    converters: ForestCard.converters,
  ),
];

bool isPrimitiveValue(Card card, {required bool elseNull}) {
  final Object? defaultValue = card.defaultValue;
  if (defaultValue == null) return elseNull;

  return card.type.isCorrectType(defaultValue);
}

Object? getTestValueBasedOnDefaultValue(Card<Object?> card) {
  final Object? defaultValue = card.defaultValue;
  if (defaultValue == null) return null;
  return switch (card.type) {
    DataType.string => (defaultValue as String) + '_test',
    DataType.int => (defaultValue as int) * 2,
    DataType.double => (defaultValue as double) + 1.11111,
    DataType.bool => !(defaultValue as bool),
    DataType.stringList => (defaultValue as List<String>) + ['_test'],
  };
}

String getReason(String message, Card card) => '''
$message
Broken on card: $card
''';

class CardotekaTest extends Cardoteka
    with WatcherImpl, WatcherImplDebug, CardotekaUtilsForTest, AccessToSP {
  CardotekaTest({required super.config});
}

typedef AsyncCallback = Future<void> Function();

Future<void> testWith(
  Object description,
  dynamic Function() body, {
  dynamic Function()? setUp,
  dynamic Function()? tearDown,
}) async {
  test(description, () async {
    await setUp?.call();
    await body.call();
    await tearDown?.call();
  });
}

Future<void> main() async {
  for (final config in cardsCollections) {
    late CardotekaTest cardoteka;
    Future<void> setUpAction() async {
      cardoteka = CardotekaTest(config: config);
      cardoteka.setMockInitialValues({});
      await Cardoteka.init();
    }

    Future<void> tearDownAction() async {
      cardoteka.deInit();
    }

    await testWith(
      '$WatcherImpl.attach -> Checking operations that call a callback',
      setUp: setUpAction,
      tearDown: tearDownAction,
      () async {
        for (final card in cardoteka.cards) {
          if (!isPrimitiveValue(card, elseNull: true)) continue;

          final Object? defaultValue = card.defaultValue;
          final Object? newValue = getTestValueBasedOnDefaultValue(card);
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
              reason: getReason(
                'The callback should return a new value as soon as it changes in the store'
                '$actionForResultInCallback, when count is $counter',
                card,
              ),
            ),
            detacher: (_) => detacher = _,
          );

          await Future.wait(actionForResultInCallback.map((e) => e.$1.call()));

          expect(
            actionForResultInCallback,
            hasLength(counter),
            reason: getReason(
              'All operations must trigger the callback!'
              '${cardoteka.getWatchers()}',
              card,
            ),
          );
          detacher.call();
        }
      },
    );

    await testWith(
      '$WatcherImpl.attach -> What does attach return when storage is empty?',
      setUp: setUpAction,
      tearDown: tearDownAction,
      () async {
        for (final card in cardoteka.cards) {
          final value = cardoteka.attach(card, (_) {}, detacher: (_) {});
          expect(
            value,
            card.defaultValue,
            reason: getReason(
              'Should always return to default value!',
              card,
            ),
          );
        }
      },
    );

    await testWith(
      '$WatcherImpl.attach -> What does attach return when storage contains value?',
      setUp: setUpAction,
      tearDown: tearDownAction,
      () async {
        for (final card in cardoteka.cards) {
          if (!isPrimitiveValue(card, elseNull: false)) continue;

          final testedValue = getTestValueBasedOnDefaultValue(card);
          final isSuccess = await cardoteka.setOrNull(
            card,
            getTestValueBasedOnDefaultValue(card),
          );
          // todo: this is a separate check when testing the cardoteka
          expect(
            isSuccess,
            isTrue,
            reason: getReason(
              'The value must be saved in the storage',
              card,
            ),
          );

          final value = cardoteka.attach(card, (_) {}, detacher: (_) {});
          expect(
            value,
            testedValue,
            reason: getReason(
              'Should return a value that is contained in the storage!',
              card,
            ),
          );
        }
      },
    );

    await testWith(
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
            reason: getReason(
              'The number of callbacks must be equal to the number of attachments!',
              card,
            ),
          );
        }
      },
    );

    await testWith(
      '$WatcherImpl.attach -> fireImmediately',
      setUp: setUpAction,
      tearDown: tearDownAction,
      () async {
        for (final card in cardoteka.cards) {
          bool wasCalled = false;
          cardoteka.attach(
            card,
            (_) => wasCalled = true,
            detacher: (_) {},
            fireImmediately: false,
          );

          expect(
            wasCalled,
            isFalse,
            reason: getReason(
              'when fireImmediately=false callback should NOT be called immediately!',
              card,
            ),
          );

          wasCalled = false;
          cardoteka.attach(
            card,
            (_) => wasCalled = true,
            detacher: (_) {},
            fireImmediately: true,
          );

          expect(
            wasCalled,
            isTrue,
            reason: getReason(
              'when fireImmediately=true callback must be called immediately!',
              card,
            ),
          );
        }
      },
    );
  }
}

// todo:
//   test('Detacher Functional Check', () async {});
//   test('More than one listener per card', () async {});
