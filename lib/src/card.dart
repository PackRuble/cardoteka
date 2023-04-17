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

/// Cards for using the [Cardoteka] service.
/// (!) When creating cards, be sure to use a generic type that matches your value
/// or the value of the conversion result [Converter.to].
///
/// [type] -> type of data to be saved;
/// [key] -> the [Cardoteka] service uses this key to access [SharedPreferences];
/// [defaultValue] -> default value for this key (for type [V]).
///
///
/// It is assumed to be implemented with [dc.Enum] for key definition.
/// However, a regular `class` will also work.
abstract class Card<V extends dc.Object?> {
  /// Type of data to be saved.
  DataType get type;

  /// The default value for this key [Card].
  V get defaultValue;

  /// The key to access the value [defaultValue] in the [Cardoteka].
  dc.String get key;
}
