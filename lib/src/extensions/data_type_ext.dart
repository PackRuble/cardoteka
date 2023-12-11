import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:meta/meta.dart';

import '../card.dart';

/// Extended functionality [DataType].
@internal
extension DataTypeExt on DataType {
  /// Get dart type.
  @internal
  Type getDartType() {
    switch (this) {
      case DataType.bool:
        return bool;
      case DataType.int:
        return int;
      case DataType.double:
        return double;
      case DataType.string:
        return String;
      case DataType.stringList:
        return List<String>;
    }
  }

  /// Checks that the type of the specified value is the same as the valid value.
  ///
  /// Note(!): in the web, the [double] and [int] types can coincide. Read more here:
  /// https://dart.dev/guides/language/numbers
  @internal
  bool isCorrectType<T extends Object>(T value) {
    if (kIsWeb &&
        (value is double || value is int) &&
        (this == DataType.bool || this == DataType.int)) return true;

    switch (this) {
      case DataType.bool:
        return value is bool;
      case DataType.int:
        return value is int;
      case DataType.double:
        return value is double;
      case DataType.string:
        return value is String;
      case DataType.stringList:
        return value is List<String>;
    }
  }
}
