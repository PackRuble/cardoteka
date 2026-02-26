import 'dart:core' as dc;

import 'package:meta/meta.dart' show reopen, visibleForTesting;

// coverage:ignore-file

// todo(26.02.2026, @PackRuble): move to separate file
/// Type of data to be saved.
enum DataType<V extends dc.Object> {
  /// Represents type [dc.bool].
  bool<dc.bool>(),

  /// Represents type [dc.int].
  int<dc.int>(),

  /// Represents type [dc.double].
  double<dc.double>(),

  /// Represents type [dc.String].
  string<dc.String>(),

  /// Represents type [dc.List]<[dc.Object]?>.
  list<dc.List<dc.Object?>>(),

  /// Represents type [dc.Map]<[dc.String], [dc.Object]?>.
  map<dc.Map<dc.String, dc.Object?>>(),

  // todo(26.02.2026, @PackRuble): Is it necessary for manual castings (undetermined data)?
  object<dc.Object>(),
  ;

  dc.Type get type => V;

  // todo(09.02.2026, @PackRuble): add list, map
  static DataType<V> typeBy<V extends dc.Object>(V value) {
    return switch (value) {
      dc.bool() => DataType.bool,
      dc.int() => DataType.int,
      dc.double() => DataType.double,
      dc.String() => DataType.string,
      dc.List<dc.Object?>() => DataType.list,
      dc.Map<dc.String, dc.Object?>() => DataType.map,
      dc.Object() => DataType.object,
      // _ => throw dc.ArgumentError('Unsupported DataType: ${value.runtimeType}'),
    } as DataType<V>;
  }

  V? cast(dc.Object? value) {
    if (value == null) return null;

    return switch (this) {
      DataType.list => (value as dc.List).cast<dc.Object?>(),
      DataType.map => (value as dc.Map).cast<dc.String, dc.Object?>(),
      _ => value,
    } as V?;
  }
}

// todo(22.02.2026, @PackRuble): doc
/// Cards for using the [CardotekaCore] implementation.
///
/// You may not specify a generic when implementing, in which case the type
/// will be inferred automatically based on the specified [defaultValue].
/// In general this works fine, however note that
/// if [defaultValue]=null then the inferred type will be [dynamic].
///
/// The card consists of:
/// - [type] -> type of data to be saved;
/// - [key] -> the cardoteka impl uses this key to access SharedPreferences;
/// - [defaultValue] -> default value for this key (for type [V]).
///
/// It is assumed to be implemented with [dc.Enum] for key definition. Here's an
/// uncomplicated example of simple data:
/// ```dart
/// enum SettingsCard implements Card<Object> {
///   homeIndex(DataType.int, 1),
///   relativePathSettings(DataType.string, r'%MYDOCUMENTS%\app_settings\'),
///   aspectLayout(DataType.double, 0.32),
///   listCodes(DataType.stringList, ['error', '403', '2030']),
///   ;
///
///   const SettingsCard(this.type, this.defaultValue);
///
///   @override
///   final DataType type;
///
///   @override
///   final Object defaultValue;
///
///   @override
///   String get key => name;
/// }
/// ```
/// For each card you can use a generic type and converters as needed.
///
/// However, a regular `class` will also work.
abstract interface class Card<V extends dc.Object?> {
  /// Type of data to be saved. Select the one that matches either the type
  /// of your [defaultValue] or the type after using the [Converter.to]
  /// converter method.
  DataType<dc.Object> get type;

  /// The default value for this [Card].
  V get defaultValue;

  /// The key to access the value in the SharedPreferences store.
  dc.String get key;

  @dc.override
  dc.String toString() => '$runtimeType(key: $key, '
      'defaultValue: $defaultValue, '
      'type: $type)';
}

/// Designed to allow inheritance during testing.
@reopen
@visibleForTesting
abstract class CardAbstract<T> extends Card<T> {}
