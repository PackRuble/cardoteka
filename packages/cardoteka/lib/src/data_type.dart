import 'dart:core' as dc;

// coverage:ignore-file

/// Type of data to be saved.
enum DataType<V extends dc.Object> {
  /// Represents type [dc.bool].
  bool<dc.bool>(),

  /// Represents type [dc.int].
  int<dc.int>(),

  /// Represents type [dc.double].
  double<dc.double>(),

  /// Represents type [dc.String].
  string<dc.String>(),

  /// Represents type [dc.Iterable]<[dc.Object]?>.
  list<dc.Iterable<dc.Object?>>(),

  /// Represents type [dc.Map]<[dc.String], [dc.Object]?>.
  map<dc.Map<dc.String, dc.Object?>>(),

  /// Represents type [dc.Object]. Used when type is not important.
  object<dc.Object>(),
  ;

  dc.Type get type => V;

  /// Return the [DataType] based on the [value] type.
  ///
  /// Note(!): in the web, the [dc.double] and [dc.int] types can coincide.
  /// Read more here: https://dart.dev/guides/language/numbers
  static DataType<V> typeBy<V extends dc.Object>(V value) {
    return switch (value) {
      dc.bool() => DataType.bool,
      dc.int() => DataType.int,
      dc.double() => DataType.double,
      dc.String() => DataType.string,
      dc.Iterable<dc.Object?>() => DataType.list,
      dc.Map<dc.String, dc.Object?>() => DataType.map,
      dc.Object() => DataType.object,
    } as DataType<V>;
  }
}
