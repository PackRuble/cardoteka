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

/// Key instance for using the [CardDb] service.
/// (!) When creating keys, be sure to use a generic type that matches your value
/// or the value of the conversion result [IConverter.toDb].
///
/// [type] -> type of data to be saved;
/// [key] -> the [CardDb] service uses this key to access [SharedPreferences];
/// [defaultValue] -> default value for this key (type [V]).
///
///
/// It is assumed to be implemented with [Enum] for key definition.
/// However, a regular 'class' will also work.
abstract class ICard<V extends dc.Object?> {
  /// Type of data to be saved.
  DataType get type;

  /// The default value for this key [ICard].
  V get defaultValue;

  /// The key to access the value [defaultValue] in the database [CardDb].
  dc.String get key;
}
