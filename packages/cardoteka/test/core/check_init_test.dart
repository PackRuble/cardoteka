// ignore_for_file: prefer_final_locals, prefer_const_declarations, prefer_function_declarations_over_variables, unreachable_from_main

import 'package:cardoteka/cardoteka.dart';
import 'package:cardoteka/src/core/cardoteka_sync.dart' show CardotekaTestUtils;
import 'package:flutter_test/flutter_test.dart';

import '../init_sp.dart';

final class CardotekaTest extends Cardoteka with CardotekaTestUtils {
  CardotekaTest({required super.config});
}

class CardMock<T extends Object> implements Card<T> {
  const CardMock();

  @override
  T get defaultValue => 'CardMock.defaultValue' as T;

  @override
  String get key => 'CardMock.key';

  @override
  DataType get type => DataType.string;
}

class CardMockNull<T extends Object?> implements Card<T> {
  const CardMockNull();

  @override
  T get defaultValue => 'CardMockNull.defaultValue' as T;

  @override
  String get key => 'CardMockNull.key';

  @override
  DataType get type => DataType.string;
}

void main() {
  initMockNewSP();

  late CardotekaTest cardoteka;
  late Card<Object> card;
  late Card<Object?> cardNull;
  setUp(() {
    card = const CardMock();
    cardNull = const CardMockNull();

    cardoteka = CardotekaTest(
      config: CardotekaConfig(
        name: 'CardotekaTest',
        cards: [card, cardNull],
      ),
    );
  });

  tearDown(() {
    cardoteka.deInit();
  });

  group('$Cardoteka.assertCheckInit()', () {
    test("throw when don't call initialization", () {
      void Function() resultFunc = () => cardoteka.assertCheckInit();
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });

    test('normal when call initialization', () async {
      await Cardoteka.init();
      void Function() resultFunc = () => cardoteka.assertCheckInit();
      expect(resultFunc, returnsNormally);
      expect(cardoteka.isInitialized, true);
    });
  });

  group('throw when try call data-methods without initialization', () {
    test('get', () {
      void Function() resultFunc = () => cardoteka.get(card);
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('getOrNull', () {
      void Function() resultFunc = () => cardoteka.getOrNull(card);
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('set', () {
      void Function() resultFunc =
          () async => await cardoteka.set(card, 'defaultValue_test');
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('setOrNull', () {
      void Function() resultFunc =
          () async => await cardoteka.setOrNull(card, 'card_value');
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('setOrNull when card.value=null', () {
      void Function() resultFunc =
          () async => await cardoteka.setOrNull<Object>(cardNull, null);
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('remove', () {
      void Function() resultFunc = () async => await cardoteka.remove(card);
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('removeAll', () {
      void Function() resultFunc = () async => await cardoteka.removeAll();
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('getStoredCards', () {
      void Function() resultFunc = () => cardoteka.getStoredCards();
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('containsCard', () {
      void Function() resultFunc = () => cardoteka.containsCard(card);
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('getStoredEntries', () {
      void Function() resultFunc = () => cardoteka.getStoredEntries();
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
  });
}
