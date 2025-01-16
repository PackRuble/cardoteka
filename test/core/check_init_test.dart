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
  initSP();

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
    test("throw when don't call initialization", () async {
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
    test('get', () async {
      void Function() resultFunc = () => cardoteka.get(card);
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('getOrNull', () async {
      void Function() resultFunc = () => cardoteka.getOrNull(card);
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('set', () async {
      void Function() resultFunc =
          () => cardoteka.set(card, 'defaultValue_test');
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('setOrNull', () async {
      void Function() resultFunc =
          () => cardoteka.setOrNull(card, 'card_value');
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('setOrNull when card.value=null', () async {
      void Function() resultFunc =
          () => cardoteka.setOrNull<Object>(cardNull, null);
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('remove', () async {
      void Function() resultFunc = () => cardoteka.remove(card);
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('removeAll', () async {
      void Function() resultFunc = () => cardoteka.removeAll();
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('getStoredCards', () async {
      void Function() resultFunc = () => cardoteka.getStoredCards();
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('containsCard', () async {
      void Function() resultFunc = () => cardoteka.containsCard(card);
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('getStoredEntries', () async {
      void Function() resultFunc = () => cardoteka.getStoredEntries();
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
  });
}
