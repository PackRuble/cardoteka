import 'package:flutter/foundation.dart' show kIsWeb;

import '../card.dart';

extension DataTypeExt on DataType {
  /// Get dart type.
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

// () {
// bool result;
//
// switch (this) {
//   case DataType.bool:
//     result = value is bool;
//     break;
//   case DataType.int:
//   // some checks are based on "runtimeType", which may not be accurate on the web.
//     if (kIsWeb) {
//       result = value is num;
//     } else {
//       result = value is int;
//     }
//     break;
//   case DataType.double:
//   // some checks are based on "runtimeType", which may not be accurate on the web.
//     if (kIsWeb) {
//       result = value is num;
//     } else {
//       result = value is double;
//     }
//     break;
//   case DataType.string:
//     result = value is String;
//     break;
//   case DataType.stringList:
//     result = value is List<String>;
//     break;
// }
//
// return result;
// }
