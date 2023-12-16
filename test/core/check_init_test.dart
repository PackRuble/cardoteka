// ignore_for_file: prefer_final_locals, prefer_const_declarations, prefer_function_declarations_over_variables, unreachable_from_main

import 'package:cardoteka/cardoteka.dart';
import 'package:cardoteka/src/core.dart';
import 'package:flutter_test/flutter_test.dart';

class CardotekaTest extends Cardoteka with CardotekaUtilsForTest {
  CardotekaTest({required super.config});
}

class CardMock<T extends Object> implements Card<T> {
  const CardMock();

  @override
  T get defaultValue => throw UnimplementedError();

  @override
  String get key => throw UnimplementedError();

  @override
  DataType get type => throw UnimplementedError();
}

void main() {
  late CardotekaTest cardoteka;
  late Card<Object> card;
  setUp(() {
    cardoteka = CardotekaTest(config: const CardotekaConfig(name: '', cards: []));
    cardoteka.setMockInitialValues({});

    card = const CardMock();
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
      void Function() resultFunc = () => cardoteka.set(card, 0);
      expect(resultFunc, throwsAssertionError);
      expect(cardoteka.isInitialized, false);
    });
    test('setOrNull', () async {
      void Function() resultFunc = () => cardoteka.setOrNull(card, 0);
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
    test('getCards', () async {
      void Function() resultFunc = () => cardoteka.removeAll();
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
