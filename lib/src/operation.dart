import 'core.dart';

/// Work with the database using familiar crud operations.
mixin CRUDOperation on DbBase {
  /// Calls a function [DbBase.get].
  T read<T>(RKey<T> rKey) => super.get<T>(rKey);

  /// Calls a function [DbBase.set] with  default value.
  Future<bool> create<T>(RKey<T> rKey) async =>
      super.set<T>(rKey, rKey.defaultValue);

  /// Calls a function [DbBase.set].
  /// (!) Always use a generic type. This will allow not to make a mistake,
  /// if the type of the provided value will be different from the base type of the key.
  Future<bool> update<T>(RKey<T> rKey, T newValue) async =>
      super.set<T>(rKey, newValue);

  /// Calls a function [DbBase.remove].
  Future<bool> delete(RKey rKey) async => super.remove(rKey);
}
