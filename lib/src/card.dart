import 'dart:core' as dc;

/// Type of data to be saved.
enum DataType {
  /// Represents type [dc.bool].
  bool(),

  /// Represents type [dc.int].
  int(),

  /// Represents type [dc.double].
  double(),

  /// Represents type [dc.String].
  string(),

  /// Represents type [dc.List]<[dc.String]>.
  stringList(),
}

/// Cards for using the [Cardoteka] implementation.
///
/// You may not specify a generic when implementing, in which case the type
/// will be inferred automatically based on the specified [defaultValue].
/// In general this works fine, however note that
/// if [defaultValue]=null then the inferred type will be [dynamic].
///
/// The card consists of:
/// - [type] -> type of data to be saved;
/// - [key] -> the cardoteka impl uses this key to access [SharedPreferences];
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
abstract class Card<V extends dc.Object?> {
  /// Type of data to be saved. Select the one that matches either the type
  /// of your [defaultValue] or the type after using the [Converter.to]
  /// converter method.
  DataType get type;

  /// The default value for this [Card].
  V get defaultValue;

  /// The key to access the value in the [SharedPreferences] store.
  dc.String get key;

  @dc.override
  dc.String toString() => '$runtimeType(key: $key, '
      'defaultValue: $defaultValue, '
      'type: $type)';
}
