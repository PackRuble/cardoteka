enum TypeSaved { bool, int, double, string, stringList, color }

/// Key instance for using the [DbBase] service.
/// (!) When creating keys, be sure to use a generic type that matches your value.
///
/// [type] -> type of data to be saved;
/// [key] -> the [DbBase] service uses this key to access [SharedPreferences];
/// [defaultValue] -> default value for this key. Could be null.
///
///
/// It is assumed to be implemented with [Enum] for key definition.
/// However, a regular 'class' will also work.
///
abstract class RKey<T> {
  TypeSaved get type;

  T get defaultValue;

  String get key;
}