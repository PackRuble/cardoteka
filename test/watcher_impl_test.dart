// @dart = 3.2

// ignore_for_file: prefer_interpolation_to_compose_strings

import 'package:cardoteka/cardoteka.dart';
import 'package:cardoteka/src/core.dart' show CardotekaUtilsForTest;
import 'package:cardoteka/src/extensions/data_type_ext.dart';
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
    DataType.double => (defaultValue as double) + 0.1,
    DataType.bool => !(defaultValue as bool),
    DataType.stringList => (defaultValue as List<String>) + ['_test'],
  };
}

String getReason(String message, Card card) => '''
$message
Broken on cards: $card
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
      print('setUp');
      cardoteka = CardotekaTest(config: config);
      cardoteka.setMockInitialValues({});
      await Cardoteka.init();
    }

    Future<void> tearDownAction() async {
      print('tearDown');
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
          cardoteka.printAllWatchers();
          await Future.wait(actionForResultInCallback.map((e) => e.$1.call()));

          expect(
            actionForResultInCallback,
            hasLength(counter),
            reason: getReason(
              'All operations must trigger the callback',
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
          final value = cardoteka.attach(card, (_) {}, detacher: null);
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
          expect(
            isSuccess,
            isTrue,
            reason: getReason(
              'The value must be saved in the storage',
              card,
            ),
          );

          final value = cardoteka.attach(card, (_) {}, detacher: null);
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
  }
}

// todo:
//   test('Registering several callbacks', () async {});
//   test('Detacher Functional Check', () async {});
//   test('More than one listener per card', () async {});
//   test('FireImmediately', () async {});