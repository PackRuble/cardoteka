import 'package:cardoteka/src/converter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../source/converters.dart';
import '../source/models.dart';

void main() {
  group('$Converter', () {
    // todo(21.02.2026, @PackRuble): move
    // test('colorAsInt', () {
    //   // ignore: deprecated_member_use_from_same_package
    //   const converter = Converters.colorAsInt;
    //   const color = Color.fromARGB(0, 0, 0, 0);
    //   // ignore: deprecated_member_use
    //   final colorValue = color.value;
    //
    //   int resultTo = converter.to(color);
    //   expect(resultTo, colorValue);
    //   expect(resultTo, isA<int>());
    //
    //   Color resultFrom = converter.from(colorValue);
    //   expect(resultFrom, color);
    //   expect(resultFrom, isA<Color>());
    // });

    test('$UriConverter', () {
      const converter = UriConverter<Uri?, String?>();

      const uriRaw = 'https://pub.dev/packages/cardoteka';
      final uri = Uri.tryParse(uriRaw);

      dynamic result = converter.to(uri);
      expect(result, uriRaw);
      expect(result, isA<String?>());

      result = converter.from(uriRaw);
      expect(result, uri);
      expect(result, isA<Uri?>());
    });

    test('$DurationConverter', () {
      const converter = DurationConverter<Duration, int>();

      const duration = Duration(days: 1);
      final durationRaw = duration.inMicroseconds;

      dynamic result = converter.to(duration);
      expect(result, durationRaw);
      expect(result, isA<int>());

      result = converter.from(durationRaw);
      expect(result, duration);
      expect(result, isA<Duration>());
    });

    test('$DateTimeConverter', () {
      const converter = DateTimeConverter<DateTime, String>();

      final datetime = DateTime.now();
      final datetimeRaw = datetime.toIso8601String();

      dynamic result = converter.to(datetime);
      expect(result, datetimeRaw);
      expect(result, isA<String>());

      result = converter.from(datetimeRaw);
      expect(result, datetime);
      expect(result, isA<DateTime>());
    });

    test('$DateTimeAsIntConverter', () {
      const converter = DateTimeAsIntConverter<DateTime, int>();

      final datetime = DateTime.parse('2023-08-01 10:32:02.398');
      final datetimeRaw = datetime.millisecondsSinceEpoch;

      dynamic result = converter.to(datetime);
      expect(result, datetimeRaw);
      expect(result, isA<int>());

      result = converter.from(datetimeRaw);
      expect(result, datetime);
      expect(result, isA<DateTime>());
    });

    test('$NumConverter', () {
      const converter = NumConverter<num, double>();

      const num number = 1.13101;
      final numberRaw = number.toDouble();

      dynamic result = converter.to(number);
      expect(result, numberRaw);
      expect(result, isA<double>());

      result = converter.from(numberRaw);
      expect(result, number);
      expect(result, isA<num>());
    });

    test('$NumAsStringConverter', () {
      const converter = NumAsStringConverter<num, String>();

      const num number = 1.13101;
      final numberRaw = number.toString();

      dynamic result = converter.to(number);
      expect(result, numberRaw);
      expect(result, isA<String>());

      result = converter.from(numberRaw);
      expect(result, number);
      expect(result, isA<num>());
    });

    test('$EnumAsStringConverter', () {
      const converter = EnumAsStringConverter(Theme.values);

      const theme = Theme.orange;
      final themeRaw = theme.name;

      dynamic result = converter.to(theme);
      expect(result, themeRaw);
      expect(result, isA<String>());

      result = converter.from(themeRaw);
      expect(result, theme);
      expect(result, isA<Theme>());
    });

    test('$EnumAsIntConverter', () {
      const converter = EnumAsIntConverter(Theme.values);

      const theme = Theme.orange;
      final themeRaw = theme.index;

      dynamic result = converter.to(theme);
      expect(result, themeRaw);
      expect(result, isA<int>());

      result = converter.from(themeRaw);
      expect(result, theme);
      expect(result, isA<Theme>());
    });

    group('$CollectionConverter with $User', () {
      const testItem = User('Carl', 18);
      final Iterable<User> items = [
        testItem,
        const User('Mark', 21),
        const User('Bella', 43),
        const User('Klara', 49),
      ].map((e) => e);

      test('$IterableConverter.to->from', () {
        const converter = UserIterableConverter();

        const item = testItem;
        final itemRaw = testItem.toJson();

        final resultTo = converter.to(item);
        expect(resultTo, isA<Map<String, dynamic>>());
        expect(resultTo, itemRaw);

        final resultFrom = converter.from(itemRaw);
        expect(resultFrom, isA<User>());
        expect(resultFrom.name, item.name);
      });

      test('$IterableConverter.itemsTo->itemsFrom', () {
        const converter = UserIterableConverter();

        final itemsRaw = items.map((e) => e.toJson());

        final resultTo = converter.itemsTo(items);
        expect(resultTo, itemsRaw);
        expect(resultTo, isA<Iterable<Map<String, dynamic>>>());
        expect(resultTo, itemsRaw);
        expect(resultTo, hasLength(items.length));

        final resultFrom = converter.itemsFrom(itemsRaw);
        expect(resultFrom, isA<Iterable<User>>());
        expect(resultFrom, hasLength(items.length));
      });

      test('$ListConverter.itemsTo->itemsFrom', () {
        const converter = UserListConverter();

        final itemsRaw = items.map((e) => e.toJson()).toList();

        final resultTo = converter.itemsTo(items.toList());
        expect(resultTo, itemsRaw);
        expect(resultTo, isA<List<Map<String, dynamic>>>());
        expect(resultTo, itemsRaw);
        expect(resultTo, hasLength(items.length));

        final resultFrom = converter.itemsFrom(itemsRaw);
        expect(resultFrom, isA<List<User>>());
        expect(resultFrom, hasLength(items.length));
      });

      test('$MapUserToListConverter.itemsTo->itemsFrom', () {
        const converter = MapUserToListConverter();

        final itemsMap = Map<String, User>.fromIterable(
          items,
          key: (element) => (element as User).name,
        );

        final resultTo = converter.itemsTo(itemsMap);
        expect(resultTo, isA<List<String>>());
        expect(resultTo, hasLength(items.length));

        final resultFrom = converter.itemsFrom(resultTo);
        expect(resultFrom, isA<Map<String, User>>());
        expect(resultFrom, hasLength(items.length));
      });
    });
  });
}
