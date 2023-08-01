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

import 'package:cardoteka/src/extensions/enum.dart';

/// Use to transform a complex model for work to [Cardoteka].
abstract class Converter<Element extends Object?, ElementJson extends Object> {
  const Converter();

  Element from(ElementJson data);
  ElementJson to(Element object);

  @override
  String toString() => '$runtimeType(from: $Element, to: $ElementJson)';
}

/// Use to transform a internal [Object] for work to [Cardoteka].
abstract class CollectionConverter<
    Collect extends Object,
    Element extends Object,
    CollectJson extends Object,
    ElementJson extends Object> implements Converter<Collect, CollectJson> {
  const CollectionConverter();

  Element objFrom(ElementJson element);
  ElementJson objTo(Element object);

  @override
  Collect from(CollectJson elements);

  @override
  CollectJson to(Collect object);

  @override
  String toString() =>
      '$runtimeType(from: $Collect<$Element>, to: $CollectJson<$ElementJson>)';
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
extension EnumConverters on Converters {
  /// Convert [Enum] to [String]. Not dependent on [Enum.index]. Preferred method.
  ///
  /// Warning! This is a [EnumName.name]-dependent converter. This means that
  /// if your enumeration name changes (for example, if you rename your
  /// enumeration value), the first item in the enumeration list will be returned.
  ///
  /// For better control of enum names, simply override [EnumName.name]
  /// and assign a permanent name.
  static Converter<T, String> enumAsString<T extends Enum>(List<T> enums) =>
      EnumAsStringConverter(enums);

  /// Convert [Enum] to [int]. Not dependent on [EnumName.name].
  ///
  /// Warning! This is a [Enum.index]-dependent converter. This means that
  /// if your enumeration index changes (for example, if you move your
  /// enumeration value), the first item in the enumeration list will be returned.
  static Converter<T, int> enumAsInt<T extends Enum>(List<T> enums) =>
      EnumAsIntConverter(enums);
}

/// The converter allows you to save the [Color] class to the storage as [int].
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

  final List<T> _enums;

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

  final List<T> _enums;

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
/// Converts [Iterable]<[T]> to [List]<[String]> using [Iterable.toList].
///
abstract class IterableConverter<Element extends Object>
    implements
        CollectionConverter<Iterable<Element>, Element, List<String>, String> {
  const IterableConverter();

  @override
  Element objFrom(String data);

  @override
  String objTo(Element obj);

  @override
  Iterable<Element> from(List<String> data) => data.map((e) => objFrom(e));

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
  String objTo(Element obj);

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
abstract class MapConverter<K, V>
    implements
        CollectionConverter<Map<K, V>, MapEntry<K, V>, List<String>, String> {
  const MapConverter();

  @override
  MapEntry<K, V> objFrom(String element);

  @override
  String objTo(MapEntry<K, V> obj);

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

/// todo: add converters
/// - Records after upgrade dart >3.0.0
