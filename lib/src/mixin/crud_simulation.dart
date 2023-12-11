import '../card.dart';
import '../core.dart';

/// Work with the [Cardoteka] using familiar CRUD operations.
///
/// The work is only possible with non-nullable cards.
mixin CRUD on Cardoteka {
  /// Calls [Cardoteka.get] method.
  V read<V extends Object>(Card<V> card) => super.get<V>(card);

  /// Calls [Cardoteka.set] method with a [Card.defaultValue].
  ///
  /// Specify your [value] if necessary.
  Future<bool> create<V extends Object>(
    Card<V> card, [
    V? value,
  ]) async =>
      super.set<V>(card, value ?? card.defaultValue);

  /// Calls [Cardoteka.set] method.
  Future<bool> update<V extends Object>(Card<V> card, V value) async =>
      super.set<V>(card, value);

  /// Calls [Cardoteka.remove] method.
  Future<bool> delete(Card card) async => super.remove(card);
}
