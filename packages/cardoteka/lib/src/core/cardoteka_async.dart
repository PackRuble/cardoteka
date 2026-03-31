import 'dart:async';

import 'package:meta/meta.dart';

import '../card.dart';
import '../converter.dart';
import '../data_type.dart';
import 'cardoteka_core.dart';
import 'storage/cardoteka_storage.dart';

/// Asynchronous implementation of a [CardotekaCore].
///
/// {@macro cardoteka.CardotekaCore}
// todo(20.02.2026, @PackRuble):
/// A complete example of working with the asynchronous version of [CardotekaAsync]:
/// ```dart
/// main() async {
///   // for the asynchronous version, initialization is not needed.
///   final cardoteka = CardotekaAsync(
///     config: CardotekaConfig(
///       name: 'settings',
///       cards: SettingsCards.values,
///       converters: SettingsCards.converters,
///     ),
///   );
///
///   // and further, all `get` and `getOrNull` are asynchronous operations
///   // also applies to `getStoredCards` and `getStoredEntries`
///
///   ThemeMode themeMode = await cardoteka.get(SettingsCards.themeMode); // will return default value
///   await cardoteka.set<ThemeMode>(SettingsCards.themeMode, ThemeMode.light);
///   themeMode = await cardoteka.get(SettingsCards.themeMode); // ThemeMode.light
///
///   DateTime? lastLoginTime = await cardoteka.getOrNull(SettingsCards.lastLoginTime); // null
///   await cardoteka.setOrNull<DateTime>(SettingsCards.lastLoginTime, DateTime.now());
///   lastLoginTime = await cardoteka.getOrNull(SettingsCards.lastLoginTime); // will return the saved time
///
///   await cardoteka.getStoredCards(); // {SettingsCards.themeMode, SettingsCards.lastLoginTime}
///
///   await cardoteka.remove(SettingsCards.userColor); // nothing will happen
///   await cardoteka.remove(SettingsCards.lastLoginTime); // lastLoginTime removed from storage
///   await cardoteka.getStoredEntries(); // {SettingsCards.themeMode: ThemeMode.light}
///
///   await cardoteka.removeAll();
///   await cardoteka.getStoredCards(); // {}
/// }
/// ```
base class CardotekaAsync extends CardotekaCore {
  /// {@macro cardoteka.CardotekaCore.constructor}
  /// and create an instance of the [CardotekaAsync].
  CardotekaAsync({
    required super.config,
    required CardotekaStorage storage,
  }) : _storage = storage;

  /// Used to access storage.
  final CardotekaStorage _storage;

  @override
  FutureOr<V> get<V extends Object?>(Card<V> card) async {
    return await getValueFromStorage<V>(card) as V;
  }

  @override
  FutureOr<V> getOrDefault<V extends Object?>(Card<V> card) async {
    return await getValueFromStorage<V>(card) ?? card.defaultValue;
  }

  @internal
  @protected
  @override
  FutureOr<V?> getValueFromStorage<V extends Object?>(Card<V> card) async {
    final Object? object = await getObjectFromStorage(card.key, card.dartType);

    if (object == null) {
      return null;
    } else {
      return (switch (getConverter(card)) {
            null => null,
            final CollectionConverter converter => converter.itemsFrom(object),
            final Converter converter => converter.from(object),
          } ??
          object) as V;
    }
  }

  @internal
  @protected
  @override
  FutureOr<Object?> getObjectFromStorage(String key, DataType type) async {
    return _storage.get(key, type);
  }

  @override
  // is required to explicitly specify that the method to be implemented can be
  // either synchronous or asynchronous, while returning void
  // ignore_for_file: avoid_futureor_void
  FutureOr<void> set<V extends Object?>(Card<V> card, V value) async {
    watcher?.notify<V?>(card, value);

    await setValueToStorage<V>(card, value);
  }

  @internal
  @protected
  @override
  FutureOr<void> setValueToStorage<V extends Object?>(
    Card<V> card,
    V value,
  ) async {
    final resultValue = switch (getConverter(card)) {
          final CollectionConverter converter => converter.itemsTo(value),
          final Converter converter => converter.to(value),
          null => null,
        } ??
        value;
    await _storage.set(card.key, resultValue, card.dartType);
  }

  @override
  @protected
  FutureOr<void> setObjectToStorage<V extends Object>(
    String key,
    V? value,
  ) async =>
      _storage.set<V>(
        key,
        value,
        value != null ? DataType.typeBy<V>(value) : null,
      );

  @override
  FutureOr<void> remove(Card card) async {
    watcher?.notifyAboutRemove([card]);
    await _storage.remove(card.key);
  }

  @override
  FutureOr<void> removeAll() async {
    watcher?.notifyAboutRemove(cards);
    await _storage.clear();
  }

  @override
  FutureOr<bool> containsCard(Card card) async =>
      _storage.containsKey(card.key);

  @override
  FutureOr<Set<Card>> getStoredCards() async {
    final Set<String> storedKeys = await _storage.getKeys(
      onlyKeys: {for (final card in cards) card.key},
    );
    final resultKeys = <Card>{
      for (final card in cards)
        if (storedKeys.contains(card.key)) card
    };

    return resultKeys;
  }

  @override
  FutureOr<Map<Card, Object>> getStoredEntries() async {
    return {
      for (final card in await getStoredCards())
        card: (await getValueFromStorage<Object?>(card))!
    };
  }

  // todo(03.03.2026, @PackRuble): replace FutureOr with Future in the implementation,
  //  since. Future has many useful methods
  @override
  FutureOr<void> reloadCache() async {
    await _storage.reloadCache();

    if (watcher != null) {
      final storedCards = await getStoredCards();
      final mayHaveBeenRemoved = cards.toSet().difference(storedCards);
      watcher?.notifyAboutRemove(mayHaveBeenRemoved.toList());
      watcher?.notifyAll();
    }
  }
}
