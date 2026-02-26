// todo(20.02.2026, @PackRuble):
// import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:meta/meta.dart';

import '../card.dart';

/// Extended functionality [DataType].
@internal
// todo(26.02.2026, @PackRuble): delete
extension DataTypeExt on DataType {
  /// Get dart type.
  @internal
  Type get dartType => switch (this) {
        DataType.bool => bool,
        DataType.int => int,
        DataType.double => double,
        DataType.string => String,
        DataType.list => List<String>,
        DataType.map => Map<String, Object>,
        DataType.object => Object,
      };

  /// Checks that the type of the specified value is the same as the valid value.
  ///
  /// Note(!): in the web, the [double] and [int] types can coincide. Read more here:
  /// https://dart.dev/guides/language/numbers
  @internal
  bool isCorrectType<T extends Object>(T value) {
    if (
        // kIsWeb &&
        (value is double || value is int) &&
            (this == DataType.bool || this == DataType.int)) return true;

    return switch (this) {
      DataType.bool => value is bool,
      DataType.int => value is int,
      DataType.double => value is double,
      DataType.string => value is String,
      DataType.list => value is List<String>,
      DataType.map => value is Map<String, Object?>,
      DataType.object => true,
    };
  }
}
