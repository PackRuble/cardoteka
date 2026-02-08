import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:meta/meta.dart';

import '../card.dart';

/// Extended functionality [DataType].
@internal
extension DataTypeExt on DataType {
  /// Get dart type.
  @internal
  Type get dartType => switch (this) {
        DataType.bool => bool,
        DataType.int => int,
        DataType.double => double,
        DataType.string => String,
        DataType.stringList => List<String>
      };

  /// Checks that the type of the specified value is the same as the valid value.
  ///
  /// Note(!): in the web, the [double] and [int] types can coincide. Read more here:
  /// https://dart.dev/guides/language/numbers
  @internal
  bool isCorrectType<T extends Object>(T value) {
    if (kIsWeb &&
        (value is double || value is int) &&
        (this == DataType.bool || this == DataType.int)) return true;

    return switch (this) {
      DataType.bool => value is bool,
      DataType.int => value is int,
      DataType.double => value is double,
      DataType.string => value is String,
      DataType.stringList => value is List<String>
    };
  }
}
