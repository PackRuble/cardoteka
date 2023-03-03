import 'dart:core' as dart_core;
import 'dart:ui' as ui show Color;
import 'converter.dart';

/// Type of data to be saved.
enum TypeData {
  /// Represents type [dart_core.bool].
  bool,

  /// Represents type [dart_core.int].
  int,

  /// Represents type [dart_core.double].
  double,

  /// Represents type [dart_core.String].
  string,

  /// Represents type [dart_core.List]<String>.
  stringList,

  /// Represents type [ui.Color].
  color
}

/// Key instance for using the [CardDb] service.
/// (!) When creating keys, be sure to use a generic type that matches your value.
///
/// [type] -> type of data to be saved;
/// [key] -> the [CardDb] service uses this key to access [SharedPreferences];
/// [defaultValue] -> default value for this key. Could be null.
///
///
/// It is assumed to be implemented with [Enum] for key definition.
/// However, a regular 'class' will also work.
///
abstract class ICard<V> {
  /// Type of data to be saved.
  TypeData get type;

  /// The default value for this key [ICard].
  V get defaultValue;

  /// The key to access the value [defaultValue] in the database [CardDb].
  dart_core.String get key;

  CardConfig get config;
}

class CardConfig<V> {
  CardConfig({
    required this.name,
    this.converters,
  });

  /// The name of your database. The [storeName] must be unique and not used in
  /// other instances [CardDb].
  ///
  /// The name is used as a prefix for keys.
  final dart_core.String name;

  /// Преобразование сложных моделей для сохранения в бд и обратно
  ///
  /// Переопределите, чтобы добавить [IConverter]
  final dart_core.Map<ICard<V>, IConverter>? converters;

  // final migrator;
}

