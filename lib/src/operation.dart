import 'core.dart';
import 'i_card.dart';

/// Work with the database using familiar crud operations.
mixin CRUD on CardDb {
  /// Calls a function [CardDb.get].
  T read<T extends Object>(ICard<T> storeCard) => super.get<T>(storeCard);

  /// Calls a function [CardDb.set] with  default value.
  Future<bool> create<T extends Object>(
    ICard<T> storeCard, [
    T? newValue,
  ]) async =>
      super.set<T>(storeCard, newValue ?? storeCard.defaultValue);

  /// Calls a function [CardDb.set].
  /// (!) Always use a generic type. This will allow not to make a mistake,
  /// if the type of the provided value will be different from the base type of the key.
  Future<bool> update<T extends Object>(ICard<T> storeCard, T newValue) async =>
      super.set<T>(storeCard, newValue);

  /// Calls a function [CardDb.remove].
  Future<bool> delete(ICard rKey) async => super.remove(rKey);
}
