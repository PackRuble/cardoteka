import 'dart:core'
    show
        DateTime,
        Deprecated,
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

import 'extensions/enum_ext.dart';

///  Use to convert a element to a element of allowed types.
abstract class Converter<Element extends Object?, ElementFrom extends Object?> {
  const Converter();

  Element from(ElementFrom element);

  ElementFrom to(Element object);

  @override
  String toString() => '$runtimeType(from: $Element, to: $ElementFrom)';
}

/// Use to convert a collection of elements to a collection of allowed types.
abstract base class CollectionConverter<
        Collection extends Object?,
        Element extends Object?,
        CollectionFrom extends Object?,
        ElementFrom extends Object?>
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

  static const Converter<Uri?, String?> uriAsString = _UriConverter();
  static const Converter<Duration?, int?> durationAsInt = _DurationConverter();
  static const Converter<DateTime?, String?> dateTimeAsString =
      _DateTimeConverter();
  static const Converter<DateTime?, int?> dateTimeAsInt =
      _DateTimeAsIntConverter();
  static const Converter<num?, double?> numAsDouble = _NumConverter();
  static const Converter<num?, String?> numAsString = _NumAsStringConverter();

  // fixdep(15.12.2023): there is no way to use something like a generic getter
  // [Should we have generic getters?](https://github.com/dart-lang/language/issues/1622)
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
class _UriConverter implements Converter<Uri?, String?> {
  const _UriConverter();

  @override
  Uri? from(String? data) => data != null ? Uri.parse(data) : null;

  @override
  String? to(Uri? object) => object?.toString();
}

/// Converter for class [Duration].
///
/// Converts [Duration] to [int] using [Duration.inMicroseconds].
class _DurationConverter implements Converter<Duration?, int?> {
  const _DurationConverter();

  @override
  Duration? from(int? data) =>
      data != null ? Duration(microseconds: data) : null;

  @override
  int? to(Duration? object) => object?.inMicroseconds;
}

/// Converter for class [DateTime].
///
/// [ISO 8601 Date and Time Format](https://www.iso.org/iso-8601-date-and-time-format.html)
/// as a time stamp. Unlike milliseconds since epoch, the ISO 8601 date is human
/// readable.
///
/// Converts [DateTime] to [String] using [DateTime.toIso8601String].
///
class _DateTimeConverter implements Converter<DateTime?, String?> {
  const _DateTimeConverter();

  @override
  DateTime? from(String? data) => data != null ? DateTime.parse(data) : null;

  @override
  String? to(DateTime? object) => object?.toIso8601String();
}

/// Converter for class [DateTime].
///
/// Converts [DateTime] to [int] using [DateTime.millisecondsSinceEpoch].
class _DateTimeAsIntConverter implements Converter<DateTime?, int?> {
  const _DateTimeAsIntConverter();

  @override
  DateTime? from(int? data) =>
      data != null ? DateTime.fromMillisecondsSinceEpoch(data) : null;

  @override
  int? to(DateTime? object) => object?.millisecondsSinceEpoch;
}

/// Converter for class [num].
///
/// Converts [num] to [double] using [num.toDouble].
class _NumConverter implements Converter<num?, double?> {
  const _NumConverter();

  @override
  num? from(double? data) => data;

  @override
  double? to(num? object) => object?.toDouble();
}

/// Converter for class [num].
///
/// Converts [num] to [String] using [num.toString].
class _NumAsStringConverter implements Converter<num?, String?> {
  const _NumAsStringConverter();

  @override
  num? from(String? data) => data != null ? num.parse(data) : null;

  @override
  String? to(num? object) => object?.toString();
}

/// Converter for class [Iterable].
///
/// Converts [Iterable]<[Element]> to [Iterable]<[Object]> using [Iterable.map].
abstract base class IterableConverter<Element extends Object?>
    implements
        CollectionConverter<Iterable<Element?>?, Element?, Iterable<Object?>?,
            Object?> {
  const IterableConverter();

  @override
  Element? objFrom(Object? element);

  @override
  Object? objTo(Element? object);

  @override
  Iterable<Element?>? from(Iterable<Object?>? elements) =>
      elements?.map(objFrom);

  @override
  Iterable<Object?>? to(Iterable<Element?>? objects) => objects?.map(objTo);
}

/// Converter for class [List].
///
/// Converts [List]<[Element]> to [List]<[ElementFrom]>.
abstract base class ListConverter<Element extends Object?,
        ElementFrom extends Object?>
    implements
        CollectionConverter<List<Element>?, Element, List<ElementFrom>?,
            ElementFrom> {
  const ListConverter();

  @override
  Element objFrom(ElementFrom element);

  @override
  ElementFrom objTo(Element object);

  @override
  List<Element>? from(List<ElementFrom>? elements) =>
      elements != null ? [for (final e in elements) objFrom(e)] : null;

  @override
  List<ElementFrom>? to(List<Element>? objects) =>
      objects != null ? [for (final o in objects) objTo(o)] : null;
}

/// Converter for class [Map].
///
/// Converts [Map]<[K], [V]> to [List]<[Object]>. [K] is [String].
///
/// Use a suitable delimiter for your data to represent the key-value as a `Object`.
abstract base class MapToListConverter<K extends String, V>
    implements
        CollectionConverter<Map<K, V>?, MapEntry<K, V>?, List<Object?>?,
            Object?> {
  const MapToListConverter();

  @override
  MapEntry<K, V> objFrom(Object? element);

  @override
  Object? objTo(MapEntry<K, V>? object);

  @override
  Map<K, V>? from(List<Object?>? elements) {
    if (elements == null) return null;

    final result = <K, V>{};
    for (final e in elements) {
      final entry = objFrom(e);
      result[entry.key] = entry.value;
    }
    return result;
  }

  @override
  List<Object?>? to(Map<K, V>? objects) =>
      objects != null ? [for (final o in objects.entries) objTo(o)] : null;
}
