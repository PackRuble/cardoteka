import '../card.dart';
import '../core.dart';

/// Work with the database using familiar CRUD operations.
mixin CRUD on Cardoteka {
  /// Calls [Cardoteka.get] method.
  V read<V extends Object>(Card<V> card) => super.get<V>(card);

  /// Calls [Cardoteka.set] method with a default value.
  Future<bool> create<V extends Object>(
    Card<V> card, [
    V? value,
  ]) async =>
      super.set<V>(card, value ?? card.defaultValue);

  /// Calls [Cardoteka.set] method.
  ///
  /// (!) Always use a generic type. This will allow not to make a mistake,
  /// if the type of the provided value will be different from the base type of the key.
  Future<bool> update<V extends Object>(Card<V> card, V value) async =>
      super.set<V>(card, value);

  /// Calls [Cardoteka.remove] method.
  Future<bool> delete(Card card) async => super.remove(card);
}
