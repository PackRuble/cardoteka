import 'core.dart';
import 'i_rkey.dart';

/// Work with the database using familiar crud operations.
mixin CRUD on RDatabase {
  /// Calls a function [RDatabase.get].
  T read<T>(RKey<T> rKey) => super.get<T>(rKey);

  /// Calls a function [RDatabase.set] with  default value.
  Future<bool> create<T>(RKey<T> rKey) async =>
      super.set<T>(rKey, rKey.defaultValue);

  /// Calls a function [RDatabase.set].
  /// (!) Always use a generic type. This will allow not to make a mistake,
  /// if the type of the provided value will be different from the base type of the key.
  Future<bool> update<T>(RKey<T> rKey, T newValue) async =>
      super.set<T>(rKey, newValue);

  /// Calls a function [RDatabase.remove].
  Future<bool> delete(RKey rKey) async => super.remove(rKey);
}
