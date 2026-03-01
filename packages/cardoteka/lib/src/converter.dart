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
abstract class Converter<Obj extends Object?, ObjRaw extends Object?> {
  const Converter();

  Obj from(ObjRaw objRaw);

  ObjRaw to(Obj obj);

  @override
  String toString() => '$runtimeType(from: $Obj, to: $ObjRaw)';
}

/// Use to convert a collection of elements to a collection of allowed types.
abstract base class CollectionConverter<
    Collection extends Object?,
    Item extends Object?,
    CollectionRaw extends Object?,
    ItemRaw extends Object?> implements Converter<Item, ItemRaw> {
  const CollectionConverter();

  Collection itemsFrom(CollectionRaw itemsRaw);

  CollectionRaw itemsTo(Collection items);

  @override
  String toString() =>
      '$runtimeType(from: $Collection<$Item>, to: $CollectionRaw<$ItemRaw>)';
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

/// Converter for class [Enum].
///
/// Converts [Enum] to [int] using [Enum.index].
class EnumAsIntConverter<T extends Enum> implements Converter<T, int> {
  const EnumAsIntConverter(this._enums);

  final Iterable<T> _enums;

  @override
  T from(int objRaw) => _enums.byIndexOr(objRaw, orElse: () => _enums.first);

  @override
  int to(T obj) => obj.index;
}

/// Converter for class [Enum].
///
/// Converts [Enum] to [String] using [EnumName.name].
class EnumAsStringConverter<T extends Enum> implements Converter<T, String> {
  const EnumAsStringConverter(this._enums);

  final Iterable<T> _enums;

  @override
  T from(String objRaw) => _enums.byNameOr(objRaw, orElse: () => _enums.first);

  @override
  String to(T obj) => obj.name;
}

/// Converter for class [Uri].
///
/// Converts [Uri] to [String] using [Uri.toString].
class _UriConverter implements Converter<Uri?, String?> {
  const _UriConverter();

  @override
  Uri? from(String? objRaw) => objRaw != null ? Uri.parse(objRaw) : null;

  @override
  String? to(Uri? obj) => obj?.toString();
}

/// Converter for class [Duration].
///
/// Converts [Duration] to [int] using [Duration.inMicroseconds].
class _DurationConverter implements Converter<Duration?, int?> {
  const _DurationConverter();

  @override
  Duration? from(int? objRaw) =>
      objRaw != null ? Duration(microseconds: objRaw) : null;

  @override
  int? to(Duration? obj) => obj?.inMicroseconds;
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
  DateTime? from(String? objRaw) =>
      objRaw != null ? DateTime.parse(objRaw) : null;

  @override
  String? to(DateTime? obj) => obj?.toIso8601String();
}

/// Converter for class [DateTime].
///
/// Converts [DateTime] to [int] using [DateTime.millisecondsSinceEpoch].
class _DateTimeAsIntConverter implements Converter<DateTime?, int?> {
  const _DateTimeAsIntConverter();

  @override
  DateTime? from(int? objRaw) =>
      objRaw != null ? DateTime.fromMillisecondsSinceEpoch(objRaw) : null;

  @override
  int? to(DateTime? obj) => obj?.millisecondsSinceEpoch;
}

/// Converter for class [num].
///
/// Converts [num] to [double] using [num.toDouble].
class _NumConverter implements Converter<num?, double?> {
  const _NumConverter();

  @override
  num? from(double? objRaw) => objRaw;

  @override
  double? to(num? obj) => obj?.toDouble();
}

/// Converter for class [num].
///
/// Converts [num] to [String] using [num.toString].
class _NumAsStringConverter implements Converter<num?, String?> {
  const _NumAsStringConverter();

  @override
  num? from(String? objRaw) => objRaw != null ? num.parse(objRaw) : null;

  @override
  String? to(num? obj) => obj?.toString();
}

/// Converter for class [Iterable].
///
/// Converts [Iterable]<[Item]> to [Iterable]<[ItemRaw]> using [Iterable.map].
abstract base class IterableConverter<Item extends Object?,
        ItemRaw extends Object?>
    implements
        CollectionConverter<Iterable<Item>?, Item, Iterable<ItemRaw>?,
            ItemRaw> {
  const IterableConverter();

  @override
  Iterable<Item>? itemsFrom(Iterable<ItemRaw>? itemsRaw) => itemsRaw?.map(from);

  @override
  Iterable<ItemRaw>? itemsTo(Iterable<Item>? items) => items?.map(to);
}

/// Converter for class [List].
///
/// Converts [List]<[Item]> to [List]<[ItemRaw]>.
abstract base class ListConverter<Item extends Object?, ItemRaw extends Object?>
    implements CollectionConverter<List<Item>?, Item, List<ItemRaw>?, ItemRaw> {
  const ListConverter();

  @override
  List<Item>? itemsFrom(List<ItemRaw>? itemsRaw) =>
      itemsRaw != null ? [for (final e in itemsRaw) from(e)] : null;

  @override
  List<ItemRaw>? itemsTo(List<Item>? items) =>
      items != null ? [for (final o in items) to(o)] : null;
}

/// Converter for class [Map].
///
/// Converts [Map]<[K], [V]> to [List]<[ItemRaw]>. [K] is [String].
///
/// Use a suitable delimiter for your data to represent the key-value as a `Object`.
abstract base class MapToListConverter<K extends String, V extends Object?,
        ItemRaw extends Object>
    implements
        CollectionConverter<Map<K, V>?, MapEntry<K, V>, List<ItemRaw>?,
            ItemRaw> {
  const MapToListConverter();

  @override
  MapEntry<K, V> from(ItemRaw objRaw);

  @override
  ItemRaw to(MapEntry<K, V> obj);

  @override
  Map<K, V>? itemsFrom(List<ItemRaw>? itemsRaw) {
    if (itemsRaw == null) return null;

    final result = <K, V>{};
    for (final e in itemsRaw) {
      final entry = from(e);
      result[entry.key] = entry.value;
    }
    return result;
  }

  @override
  List<ItemRaw>? itemsTo(Map<K, V>? items) =>
      items != null ? [for (final o in items.entries) to(o)] : null;
}
