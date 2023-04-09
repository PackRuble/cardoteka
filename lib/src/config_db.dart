import 'package:meta/meta.dart';
import 'package:reactive_db/src/i_card.dart';

import 'converter.dart';

@immutable
class ConfigDB {
  const ConfigDB({
    required this.name,
    this.converters,
  });

  /// The name of your database. The [storeName] must be unique and not used in
  /// other instances [CardDb].
  ///
  /// The name is used as a prefix for keys.
  final String name;

  /// Карта преобразователей сложных объектов.
  ///
  /// Переопределите, чтобы добавить [IConverter]
  final Map<ICard<Object?>, IConverter<Object?, Object>>? converters;

// final migrator;
}
