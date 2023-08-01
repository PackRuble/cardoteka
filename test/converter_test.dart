// ignore_for_file: prefer_final_locals, unreachable_from_main

import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart' show Color, ThemeMode;
import 'package:flutter_test/flutter_test.dart';

class TestItem {
  const TestItem(this.index);
  final String index;
}

class TestIterableConverter extends IterableConverter<TestItem> {
  const TestIterableConverter();

  @override
  TestItem objFrom(String data) => TestItem(data);

  @override
  String objTo(TestItem obj) => obj.index;
}

class TestListConverter extends ListConverter<int> {
  const TestListConverter();

  @override
  int objFrom(String element) => int.parse(element);

  @override
  String objTo(int obj) => obj.toString();
}

/// Values are assumed to be stored as a '---'-delimited string "key$value"
class TestMapConverter extends MapConverter<int, double> {
  const TestMapConverter();

  static const _delimiter = '---';

  @override
  MapEntry<int, double> objFrom(String element) {
    final list = element.split(_delimiter);

    return MapEntry(int.parse(list.first), double.parse(list.last));
  }

  @override
  String objTo(MapEntry<int, double> obj) =>
      '${obj.key}$_delimiter${obj.value}';
}

void main() {
  group('$Converters', () {
    test('colorAsInt', () {
      const converter = Converters.colorAsInt;
      const color = Color.fromARGB(0, 0, 0, 0);
      final colorValue = color.value;

      int resultTo = converter.to(color);
      expect(resultTo, colorValue);
      expect(resultTo, isA<int>());

      Color resultFrom = converter.from(colorValue);
      expect(resultFrom, color);
      expect(resultFrom, isA<Color>());
    });

    test('uriAsString', () {
      const converter = Converters.uriAsString;

      Uri uri = Uri.parse('https://pub.dev/packages/cardoteka');
      String uriRaw = uri.toString();

      String resultTo = converter.to(uri);
      expect(resultTo, uriRaw);
      expect(resultTo, isA<String>());

      Uri resultFrom = converter.from(uriRaw);
      expect(resultFrom, uri);
      expect(resultFrom, isA<Uri>());
    });

    test('durationAsInt', () {
      const converter = Converters.durationAsInt;

      Duration duration = const Duration(days: 1);
      int durationRaw = duration.inMicroseconds;

      int resultTo = converter.to(duration);
      expect(resultTo, durationRaw);
      expect(resultTo, isA<int>());

      Duration resultFrom = converter.from(durationRaw);
      expect(resultFrom, duration);
      expect(resultFrom, isA<Duration>());
    });

    test('dateTimeAsString', () {
      const converter = Converters.dateTimeAsString;

      DateTime datetime = DateTime.now();
      String datetimeRaw = datetime.toIso8601String();

      String resultTo = converter.to(datetime);
      expect(resultTo, datetimeRaw);
      expect(resultTo, isA<String>());

      DateTime resultFrom = converter.from(datetimeRaw);
      expect(resultFrom, datetime);
      expect(resultFrom, isA<DateTime>());
    });

    test('dateTimeAsInt', () {
      const converter = Converters.dateTimeAsInt;

      DateTime datetime = DateTime.parse('2023-08-01 10:32:02.398');
      int datetimeRaw = datetime.millisecondsSinceEpoch;

      int resultTo = converter.to(datetime);
      expect(resultTo, datetimeRaw);
      expect(resultTo, isA<int>());

      DateTime resultFrom = converter.from(datetimeRaw);
      expect(resultFrom, datetime);
      expect(resultFrom, isA<DateTime>());
    });

    test('numAsDouble', () {
      const converter = Converters.numAsDouble;

      num number = 1.10101;
      double numberRaw = number.toDouble();

      double resultTo = converter.to(number);
      expect(resultTo, numberRaw);
      expect(resultTo, isA<double>());

      num resultFrom = converter.from(numberRaw);
      expect(resultFrom, number);
      expect(resultFrom, isA<num>());
    });

    test('numAsString', () {
      const converter = Converters.numAsString;

      num number = 1.10101;
      String numberRaw = number.toString();

      String resultTo = converter.to(number);
      expect(resultTo, numberRaw);
      expect(resultTo, isA<String>());

      num resultFrom = converter.from(numberRaw);
      expect(resultFrom, number);
      expect(resultFrom, isA<num>());
    });

    test('enumAsString', () {
      final converter =
          EnumConverters.enumAsString<ThemeMode>(ThemeMode.values);

      ThemeMode mode = ThemeMode.dark;
      String modeRaw = mode.name;

      String resultTo = converter.to(mode);
      expect(resultTo, modeRaw);
      expect(resultTo, isA<String>());

      ThemeMode resultFrom = converter.from(modeRaw);
      expect(resultFrom, mode);
      expect(resultFrom, isA<ThemeMode>());
    });

    test('enumAsInt', () {
      final converter = EnumConverters.enumAsInt<ThemeMode>(ThemeMode.values);

      ThemeMode mode = ThemeMode.dark;
      int modeRaw = mode.index;

      int resultTo = converter.to(mode);
      expect(resultTo, modeRaw);
      expect(resultTo, isA<int>());

      ThemeMode resultFrom = converter.from(modeRaw);
      expect(resultFrom, mode);
      expect(resultFrom, isA<ThemeMode>());
    });
  });

  group('$IterableConverter', () {
    const converter = TestIterableConverter();

    const countItems = 5;
    const testItem = TestItem('1');
    Iterable<TestItem> items = Iterable.generate(countItems, (index) {
      if (index == countItems) return testItem;
      return TestItem(index.toString());
    });

    assert(items.length == countItems);

    test('objTo | objFrom', () {
      TestItem item = testItem;
      String itemRaw = item.index;

      String resultObjTo = converter.objTo(item);
      expect(resultObjTo, isA<String>());
      expect(resultObjTo, itemRaw);

      TestItem resultFrom = converter.objFrom(itemRaw);
      expect(resultFrom, isA<TestItem>());
      expect(resultFrom.index, item.index);
    });

    test('to | from', () {
      List<String> itemsRaw = items.map((e) => e.index).toList();

      List<String> resultTo = converter.to(items);
      expect(resultTo, itemsRaw);
      expect(resultTo, isList);
      expect(resultTo, isA<List<String>>());
      expect(resultTo, contains(testItem.index));
      expect(resultTo, hasLength(countItems));

      Iterable<TestItem> resultFrom = converter.from(itemsRaw);
      expect(resultFrom, isA<Iterable<TestItem>>());
      expect(resultFrom.map((e) => e.index), orderedEquals(itemsRaw));
      expect(resultFrom, hasLength(countItems));
    });
  });

  group('$ListConverter', () {
    const converter = TestListConverter();

    const countItems = 5;
    const testItem = 12;
    const testItemIndex = 2;
    List<int> items = List.generate(countItems, (index) => index + 10);

    assert(items.length == countItems);
    assert(testItem == items[testItemIndex]);

    test('objTo | objFrom', () {
      int item = testItem;
      String itemRaw = item.toString();

      String resultObjTo = converter.objTo(item);
      expect(resultObjTo, itemRaw);

      int resultFrom = converter.objFrom(itemRaw);
      expect(resultFrom, item);
    });

    test('to | from', () {
      List<String> itemsRaw = items.map((e) => '$e').toList();

      List<String> resultTo = converter.to(items);
      expect(resultTo, itemsRaw);
      expect(resultTo, isList);
      expect(resultTo, contains('$testItem'));
      expect(resultTo, hasLength(countItems));
      expect(resultTo, orderedEquals(itemsRaw));

      List<int> resultFrom = converter.from(itemsRaw);
      expect(resultFrom, hasLength(countItems));
      expect(resultFrom[testItemIndex], items[testItemIndex]);
      expect(resultFrom, orderedEquals(items));
    });
  });

  group('$MapConverter', () {
    const converter = TestMapConverter();

    const countItems = 5;
    Map<int, double> items =
        List<double>.generate(countItems, (index) => index * 1.1).asMap();

    test('objTo | objFrom', () {
      MapEntry<int, double> item = items.entries.first;
      String itemRaw = '0${TestMapConverter._delimiter}0.0';

      String resultObjTo = converter.objTo(item);
      expect(resultObjTo, itemRaw);

      MapEntry<int, double> resultFrom = converter.objFrom(itemRaw);
      expect(resultFrom, equals(resultFrom));
    });

    test('to | from', () {
      List<String> itemsRaw = items.entries
          .map((e) => '${e.key}${TestMapConverter._delimiter}${e.value}')
          .toList();

      List<String> resultTo = converter.to(items);
      expect(resultTo, itemsRaw);
      expect(resultTo, isList);
      expect(resultTo, hasLength(countItems));
      expect(resultTo, orderedEquals(itemsRaw));

      Map<int, double> resultFrom = converter.from(itemsRaw);
      expect(resultFrom, hasLength(countItems));
      expect(resultFrom, items);
    });
  });
}
