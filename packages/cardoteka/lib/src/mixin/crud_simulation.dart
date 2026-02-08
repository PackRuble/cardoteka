import 'dart:async';

import 'package:meta/meta.dart';

import '../card.dart';
import '../core/cardoteka_async.dart';
import '../core/cardoteka_core.dart';
import '../core/cardoteka_sync.dart';

/// Work with the [CardotekaCore] using familiar CRUD operations.
///
/// The work is only possible with non-nullable cards.
///
/// Methods such as:
/// - [CardotekaCore.get] (cannot be overridden to hide)
/// - [CardotekaCore.getOrNull] (cannot be overridden to hide)
/// - [CardotekaCore.set]
/// - [CardotekaCore.setOrNull]
/// - [CardotekaCore.remove]
/// - [CardotekaCore.removeAll]
/// have been hidden from the IDE prompts to provide clear semantics and make it
/// easier to use valid methods.
base mixin CRUD on CardotekaCore {
  /// Calls [Cardoteka.set] method with a [Card.defaultValue].
  ///
  /// Specify your [value] if necessary.
  Future<bool> create<V extends Object>(
    Card<V> card, [
    V? value,
  ]) =>
      set<V>(card, value ?? card.defaultValue);

  /// Calls [Cardoteka.get] method.
  ///
  /// NOTE: use only for [Cardoteka] successor.
  /// Using for [CardotekaAsync] successor will fail.
  V read<V extends Object>(Card<V> card) {
    final CardotekaCore instance = this;
    if (instance case Cardoteka()) {
      return instance.get<V>(card);
    } else {
      throw UnimplementedError(
        'Use the `readAsync` method, since your cardoteka instance is a successor of $CardotekaAsync',
      );
    }
  }

  /// Calls [CardotekaCore.get] method.
  Future<V> readAsync<V extends Object>(Card<V> card) async =>
      super.get<V>(card);

  /// Calls [Cardoteka.set] method.
  Future<bool> update<V extends Object>(Card<V> card, V value) =>
      set<V>(card, value);

  /// Calls [Cardoteka.remove] method.
  Future<bool> delete(Card card) => remove(card);

  /// Calls [Cardoteka.removeAll] method.
  Future<bool> clear() => removeAll();

  @override
  @protected
  @visibleForTesting
  Future<bool> set<V extends Object>(Card<V?> card, V value) =>
      super.set<V>(card, value);

  @override
  @protected
  @visibleForTesting
  Future<bool> setOrNull<V extends Object>(Card<V?> card, V? value) =>
      super.setOrNull<V>(card, value);

  @override
  @protected
  @visibleForTesting
  Future<bool> remove(Card card) => super.remove(card);

  @override
  @protected
  @visibleForTesting
  Future<bool> removeAll() => removeAll();
}
