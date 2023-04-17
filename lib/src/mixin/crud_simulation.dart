import '../core.dart';
import '../i_card.dart';

/// Work with the database using familiar CRUD operations.
mixin CRUD on CardDb {
  /// Calls [CardDb.get] method.
  T read<T extends Object>(ICard<T> card) => super.get<T>(card);

  /// Calls [CardDb.set] method with a default value.
  Future<bool> create<T extends Object>(
    ICard<T> card, [
    T? value,
  ]) async =>
      super.set<T>(card, value ?? card.defaultValue);

  /// Calls [CardDb.set] method.
  ///
  /// (!) Always use a generic type. This will allow not to make a mistake,
  /// if the type of the provided value will be different from the base type of the key.
  Future<bool> update<T extends Object>(ICard<T> card, T value) async =>
      super.set<T>(card, value);

  /// Calls [CardDb.remove] method.
  Future<bool> delete(ICard card) async => super.remove(card);
}
