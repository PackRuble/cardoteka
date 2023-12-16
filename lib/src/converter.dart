import 'dart:core'
    show
        DateTime,
        Duration,
        Enum,
        EnumName,
        Iterable,
        List,
        Map,
        MapEntry,
        Object,
        String,
        Uri,
        double,
        int,
        num,
        override;
import 'dart:ui' show Color;

import 'package:cardoteka/src/extensions/enum_ext.dart';

///  Use to convert a element to a element of allowed types.
abstract class Converter<Element extends Object?, ElementFrom extends Object> {
  const Converter();

  Element from(ElementFrom element);

  ElementFrom to(Element object);

  @override
  String toString() => '$runtimeType(from: $Element, to: $ElementFrom)';
}

/// Use to convert a collection of elements to a collection of allowed types.
abstract class CollectionConverter<
        Collection extends Object,
        Element extends Object,
        CollectionFrom extends Object,
        ElementFrom extends Object>
    implements Converter<Collection, CollectionFrom> {
  const CollectionConverter();

  Element objFrom(ElementFrom element);

  ElementFrom objTo(Element object);

  @override
  Collection from(CollectionFrom elements);

  @override
  CollectionFrom to(Collection objects);

  @override
  String toString() =>
      '$runtimeType(from: $Collection<$Element>, to: $CollectionFrom<$ElementFrom>)';
}

/// List of all available converters. Provides easy access.
class Converters {
  const Converters._();

  static const Converter<Color, int> colorAsInt = _ColorConverter();
  static const Converter<Uri, String> uriAsString = _UriConverter();
  static const Converter<Duration, int> durationAsInt = _DurationConverter();
  static const Converter<DateTime, String> dateTimeAsString =
      _DateTimeConverter();
  static const Converter<DateTime, int> dateTimeAsInt =
      _DateTimeAsIntConverter();
  static const Converter<num, double> numAsDouble = _NumConverter();
  static const Converter<num, String> numAsString = _NumAsStringConverter();

  // fixdep(15.12.2023): there is no way to use something like a generic getter
  // https://github.com/dart-lang/language/issues/1622
  static Converter<T, String> enumAsString<T extends Enum>(Iterable<T> enums) =>
      _EnumConverters.enumAsString<T>(enums);

  static Converter<T, int> enumAsInt<T extends Enum>(Iterable<T> enums) =>
      _EnumConverters.enumAsInt<T>(enums);
}

/// Provides converters to convert [Enum].
///
/// Example, save by name:
/// ```dart
/// enum Theme { system, light, dark }
///
/// class ThemeConverter implements Converter<Theme, String> {
///   const ThemeConverter();
///
///   @override
///   Theme from(String name) => Theme.values.byName(name);
///
///   @override
///   String to(Theme theme) => theme.name;
/// }
/// ```
///
/// If you want to have a const converter, just create your own or
/// use [EnumAsStringConverter] or [EnumAsIntConverter].
extension _EnumConverters on Converters {
  /// Convert [Enum] to [String]. Not dependent on [Enum.index].
  ///
  /// Warning! This is a [EnumName.name]-dependent converter. This means that
  /// if your enumeration name changes (for example, if you rename your
  /// enumeration value), the first item in the enumeration list will be returned.
  ///
  /// For better control of enum names, simply override [EnumName.name]
  /// and assign a constant name.
  static Converter<T, String> enumAsString<T extends Enum>(Iterable<T> enums) =>
      EnumAsStringConverter<T>(enums);

  /// Convert [Enum] to [int]. Not dependent on [EnumName.name].
  ///
  /// Warning! This is a [Enum.index]-dependent converter. This means that
  /// if your enumeration index changes (for example, if you move your
  /// enumeration value), the first item in the enumeration list will be returned.
  static Converter<T, int> enumAsInt<T extends Enum>(Iterable<T> enums) =>
      EnumAsIntConverter<T>(enums);
}

/// Converter for class [Color].
///
/// Converts [Color] to [int] using [Color.value].
class _ColorConverter implements Converter<Color, int> {
  const _ColorConverter();

  @override
  Color from(int value) => Color(value);

  @override
  int to(Color object) => object.value;
}

/// Converter for class [Enum].
///
/// Converts [Enum] to [int] using [Enum.index].
class EnumAsIntConverter<T extends Enum> implements Converter<T, int> {
  const EnumAsIntConverter(this._enums);

  final Iterable<T> _enums;

  @override
  T from(int index) => _enums.byIndexOr(index, orElse: () => _enums.first);

  @override
  int to(T data) => data.index;
}

/// Converter for class [Enum].
///
/// Converts [Enum] to [String] using [EnumName.name].
class EnumAsStringConverter<T extends Enum> implements Converter<T, String> {
  const EnumAsStringConverter(this._enums);

  final Iterable<T> _enums;

  @override
  T from(String name) => _enums.byNameOr(name, orElse: () => _enums.first);

  @override
  String to(T data) => data.name;
}

/// Converter for class [Uri].
///
/// Converts [Uri] to [String] using [Uri.toString].
class _UriConverter implements Converter<Uri, String> {
  const _UriConverter();

  @override
  Uri from(String data) => Uri.parse(data);

  @override
  String to(Uri object) => object.toString();
}

/// Converter for class [Duration].
///
/// Converts [Duration] to [int] using [Duration.inMicroseconds].
class _DurationConverter implements Converter<Duration, int> {
  const _DurationConverter();

  @override
  Duration from(int data) => Duration(microseconds: data);

  @override
  int to(Duration object) => object.inMicroseconds;
}

/// Converter for class [DateTime].
///
/// [ISO 8601 Date and Time Format](https://www.iso.org/iso-8601-date-and-time-format.html)
/// as a time stamp. Unlike milliseconds since epoch, the ISO 8601 date is human
/// readable.
///
/// Converts [DateTime] to [String] using [DateTime.toIso8601String].
///
class _DateTimeConverter implements Converter<DateTime, String> {
  const _DateTimeConverter();

  @override
  DateTime from(String data) => DateTime.parse(data);

  @override
  String to(DateTime object) => object.toIso8601String();
}

/// Converter for class [DateTime].
///
/// Converts [DateTime] to [int] using [DateTime.millisecondsSinceEpoch].
class _DateTimeAsIntConverter implements Converter<DateTime, int> {
  const _DateTimeAsIntConverter();

  @override
  DateTime from(int data) => DateTime.fromMillisecondsSinceEpoch(data);

  @override
  int to(DateTime object) => object.millisecondsSinceEpoch;
}

/// Converter for class [num].
///
/// Converts [num] to [double] using [num.toDouble].
class _NumConverter implements Converter<num, double> {
  const _NumConverter();

  @override
  num from(double data) => data;

  @override
  double to(num object) => object.toDouble();
}

/// Converter for class [num].
///
/// Converts [num] to [String] using [num.toString].
class _NumAsStringConverter implements Converter<num, String> {
  const _NumAsStringConverter();

  @override
  num from(String data) => num.parse(data);

  @override
  String to(num object) => object.toString();
}

/// Converter for class [Iterable].
///
/// Converts [Iterable]<[Element]> to [List]<[String]> using [Iterable.map].
///
abstract class IterableConverter<Element extends Object>
    implements
        CollectionConverter<Iterable<Element>, Element, List<String>, String> {
  const IterableConverter();

  @override
  Element objFrom(String element);

  @override
  String objTo(Element object);

  @override
  Iterable<Element> from(List<String> elements) =>
      elements.map((e) => objFrom(e));

  @override
  List<String> to(Iterable<Element> objects) =>
      [for (final o in objects) objTo(o)];
}

/// Converter for class [List].
///
/// Converts [List]<[T]> to [List]<[String]>.
///
abstract class ListConverter<Element extends Object>
    implements
        CollectionConverter<List<Element>, Element, List<String>, String> {
  const ListConverter();

  @override
  Element objFrom(String element);

  @override
  String objTo(Element object);

  @override
  List<Element> from(List<String> elements) =>
      [for (final e in elements) objFrom(e)];

  @override
  List<String> to(List<Element> objects) => [for (final o in objects) objTo(o)];
}

/// Converter for class [Map].
///
/// Converts [Map]<[K], [V]> to [List]<[String]>.
///
/// Use a suitable delimiter for your data to represent the key-value as a `String`.
abstract class MapConverter<K, V>
    implements
        CollectionConverter<Map<K, V>, MapEntry<K, V>, List<String>, String> {
  const MapConverter();

  @override
  MapEntry<K, V> objFrom(String element);

  @override
  String objTo(MapEntry<K, V> object);

  @override
  Map<K, V> from(List<String> elements) {
    final result = <K, V>{};
    for (final e in elements) {
      final entry = objFrom(e);
      result[entry.key] = entry.value;
    }
    return result;
  }

  @override
  List<String> to(Map<K, V> objects) =>
      [for (final o in objects.entries) objTo(o)];
}
