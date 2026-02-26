//
// ignore_for_file: prefer_function_declarations_over_variables

import 'package:cardoteka/cardoteka.dart' show DataType;
import 'package:cardoteka_sp/src/sp_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'init_sp.dart';

final class SpStorageTest = SpStorage with SpStorageTestUtils;

void main() {
  initMockNewSP();

  late SpStorageTest storage;

  setUp(() async {
    storage = const SpStorageTest();
    await storage.init();
  });

  tearDown(() async {
    storage.deInit();
  });

  test(
    '$SpStorageTest is Initialized',
    () async {
      storage = const SpStorageTest();
      await storage.init();
      final actualInitialize = storage.isInitialized;

      expect(
        actualInitialize,
        isTrue,
        reason: 'The storage must be initialized!',
      );
    },
  );

  test(
    '$SpStorageTest.assertCheckInit throw',
    () async {
      storage = const SpStorageTest();
      storage.deInit();

      final result = () => storage.assertCheckInit();
      expect(
        result,
        throwsAssertionError,
        reason: 'The storage must be initialized!',
      );
    },
  );

  test(
    '$SpStorageTest.assertCheckInit success',
    () async {
      storage = const SpStorageTest();
      await storage.init();
      storage.assertCheckInit();
    },
  );

  test(
    '$SpStorageTest is NOT Initialized -> throw',
    () {
      storage = const SpStorageTest();
      storage.deInit();

      dynamic result = () => storage.getKeys();
      expect(result, throwsAssertionError);
      expect(storage.isInitialized, isFalse);

      result = () => storage.getAll();
      expect(result, throwsAssertionError);
      expect(storage.isInitialized, isFalse);

      result = () => storage.get('1', DataType.string);
      expect(result, throwsAssertionError);
      expect(storage.isInitialized, isFalse);

      result = () => storage.set('2', 22, DataType.int);
      expect(result, throwsAssertionError);
      expect(storage.isInitialized, isFalse);

      result = () => storage.containsKey('3');
      expect(result, throwsAssertionError);
      expect(storage.isInitialized, isFalse);

      result = () => storage.remove('4');
      expect(result, throwsAssertionError);
      expect(storage.isInitialized, isFalse);

      result = () => storage.reloadCache();
      expect(result, throwsAssertionError);
      expect(storage.isInitialized, isFalse);
    },
  );

  test(
    '$SpStorageTest.set->get->containsKey->remove->getKeys->getAll',
    () async {
      // data
      final (String key, String value) = ('name', 'Mario');

      // actions
      await storage.set(key, value, DataType.string);

      dynamic result = storage.get(key, DataType.string);
      expect(result, value);

      result = storage.containsKey(key);
      expect(result, isTrue);

      await storage.remove(key);

      result = storage.getKeys();
      expect(result, isEmpty);

      result = storage.getAll();
      expect(result, isEmpty);
    },
  );
}
