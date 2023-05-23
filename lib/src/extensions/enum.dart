extension EnumByNameOr<T extends Enum> on Iterable<T> {
  /// Finds the enum value in this list with name [name].
  ///
  /// Goes through this collection looking for an enum with [name], as reported by [EnumName.name].
  /// Returns the first value with the given name. Such a value must be found.
  ///
  /// If no element not found, the result of invoking the [orElse]
  /// function is returned.
  /// If [orElse] is omitted, it defaults to throwing a [ArgumentError].
  T byNameOr(String name, {T Function()? orElse}) {
    for (final value in this) {
      if (value.name == name) return value;
    }

    if (orElse != null) return orElse();
    throw ArgumentError.value(name, "name", "No enum value with that name");
  }

  T byIndexOr(int index, {T Function()? orElse}) {
    RangeError.checkNotNegative(index, "index");
    final iterator = this.iterator;
    do {
      if (!iterator.moveNext()) {
        if (orElse != null) return orElse();
        throw ArgumentError.value(
            index, "index", "No enum value with that index");
      }
      // ignore: parameter_assignments
    } while (--index >= 0);
    return iterator.current;
  }
}
