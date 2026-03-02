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
extension EnumConverters<T extends Enum> on Iterable<T> {
  /// Convert [Enum] to [String]. Not dependent on [Enum.index].
  ///
  /// Warning! This is a [EnumName.name]-dependent converter. This means that
  /// if your enumeration name changes (for example, if you rename your
  /// enumeration value), the first item in the enumeration list will be returned.
  ///
  /// For better control of enum names, simply override [EnumName.name]
  /// and assign a constant name.
  Converter<T, String> get converterToString => EnumAsStringConverter(this);

  /// Convert [Enum] to [int]. Not dependent on [EnumName.name].
  ///
  /// Warning! This is a [Enum.index]-dependent converter. This means that
  /// if your enumeration index changes (for example, if you move your
  /// enumeration value), the first item in the enumeration list will be returned.
  Converter<T, int> get converterToInt => EnumAsIntConverter(this);
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
class UriConverter<Obj extends Uri?, ObjRaw extends String?>
    implements Converter<Obj, ObjRaw> {
  const UriConverter();

  @override
  Obj from(ObjRaw objRaw) => (objRaw != null ? Uri.parse(objRaw) : null) as Obj;

  @override
  ObjRaw to(Obj obj) => obj?.toString() as ObjRaw;
}

/// Converter for class [Duration].
///
/// Converts [Duration] to [int] using [Duration.inMicroseconds].
class DurationConverter<Obj extends Duration?, ObjRaw extends int?>
    implements Converter<Obj, ObjRaw> {
  const DurationConverter();

  @override
  Obj from(ObjRaw objRaw) =>
      (objRaw != null ? Duration(microseconds: objRaw) : null) as Obj;

  @override
  ObjRaw to(Obj obj) => obj?.inMicroseconds as ObjRaw;
}

/// Converter for class [DateTime].
///
/// [ISO 8601 Date and Time Format](https://www.iso.org/iso-8601-date-and-time-format.html)
/// as a time stamp. Unlike milliseconds since epoch, the ISO 8601 date is human
/// readable.
///
/// Converts [DateTime] to [String] using [DateTime.toIso8601String].
class DateTimeConverter<Obj extends DateTime?, ObjRaw extends String?>
    implements Converter<Obj, ObjRaw> {
  const DateTimeConverter();

  @override
  Obj from(ObjRaw objRaw) =>
      (objRaw != null ? DateTime.parse(objRaw) : null) as Obj;

  @override
  ObjRaw to(Obj obj) => obj?.toIso8601String() as ObjRaw;
}

/// Converter for class [DateTime].
///
/// Converts [DateTime] to [int] using [DateTime.millisecondsSinceEpoch].
class DateTimeAsIntConverter<Obj extends DateTime?, ObjRaw extends int?>
    implements Converter<Obj, ObjRaw> {
  const DateTimeAsIntConverter();

  @override
  Obj from(ObjRaw objRaw) =>
      (objRaw != null ? DateTime.fromMillisecondsSinceEpoch(objRaw) : null)
          as Obj;

  @override
  ObjRaw to(Obj obj) => obj?.millisecondsSinceEpoch as ObjRaw;
}

/// Converter for class [num].
///
/// Converts [num] to [double] using [num.toDouble].
class NumConverter<Obj extends num?, ObjRaw extends double?>
    implements Converter<Obj, ObjRaw> {
  const NumConverter();

  @override
  Obj from(ObjRaw objRaw) => objRaw as Obj;

  @override
  ObjRaw to(Obj obj) => obj?.toDouble() as ObjRaw;
}

/// Converter for class [num].
///
/// Converts [num] to [String] using [num.toString].
class NumAsStringConverter<Obj extends num?, ObjRaw extends String?>
    implements Converter<Obj, ObjRaw> {
  const NumAsStringConverter();

  @override
  Obj from(ObjRaw objRaw) => (objRaw != null ? num.parse(objRaw) : null) as Obj;

  @override
  ObjRaw to(Obj obj) => obj?.toString() as ObjRaw;
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
