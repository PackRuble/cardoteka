import 'dart:async';

import 'package:meta/meta.dart';

import '../card.dart';
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
  Future<V> get<V extends Object?>(Card<V> card) async {
    return await getValueFromStorage<V>(card) as V;
  }

  @override
  Future<V> getOrDefault<V extends Object?>(Card<V> card) async {
    return await getValueFromStorage<V>(card) ?? card.defaultValue;
  }

  @internal
  @protected
  @override
  Future<V?> getValueFromStorage<V extends Object?>(Card<V> card) async {
    final Object? object = await getObjectFromStorage(card.key, card.type);

    if (object == null) {
      return null;
    } else {
      return (getConverter(card)?.from(object) ?? object) as V;
    }
  }

  @internal
  @protected
  @override
  Future<Object?> getObjectFromStorage(String key, DataType type) async =>
      _storage.get(key, type);

  @override
  Future<void> set<V extends Object?>(Card<V> card, V value) async {
    watcher?.notify<V?>(card, value);

    await setValueToStorage<V>(card, value);
  }

  @internal
  @protected
  @override
  Future<void> setValueToStorage<V extends Object?>(
    Card<V> card,
    V value,
  ) async {
    final resultValue =
        value != null ? getConverter(card)?.to(value) ?? value : value;
    await _storage.set(card.key, resultValue, card.type);
  }

  @override
  @protected
  Future<void> setObjectToStorage<V extends Object>(
    String key,
    V? value,
  ) async =>
      _storage.set<V>(
        key,
        value,
        value != null ? DataType.typeBy<V>(value) : null,
      );

  @override
  Future<void> remove(Card card) async {
    watcher?.notify(card, null);

    await _storage.remove(card.key);
  }

  @override
  Future<void> removeAll() async {
    await _storage.clear();
    watcher?.notifyAll();
  }

  @override
  Future<bool> containsCard(Card card) async => _storage.containsKey(card.key);

  @override
  Future<Set<Card>> getStoredCards() async {
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
  Future<Map<Card, Object>> getStoredEntries() async {
    return {
      for (final card in await getStoredCards())
        card: (await getValueFromStorage<Object?>(card))!
    };
  }
}
