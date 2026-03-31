import 'package:meta/meta.dart';

import '../card.dart';
import '../data_type.dart';
import 'cardoteka_core.dart';
import 'storage/cardoteka_storage.dart';

// todo(22.02.2026, @PackRuble):
/// A synchronous implementation of a Cardoteka representing a wrapper over [SharedPreferencesWithCache].
///
/// {@macro cardoteka.CardotekaCore}
///
/// For synchronous [Cardoteka] you also need to do initialization
/// (once, though idempotent) via [Cardoteka.init].
///
/// A complete example of working with the asynchronous version of [Cardoteka]:
/// ```dart
/// main() async {
///   await Cardoteka.init();
///
///   final cardoteka = Cardoteka(
///     config: CardotekaConfig(
///       name: 'settings',
///       cards: SettingsCards.values,
///       converters: SettingsCards.converters,
///     ),
///   );
///
///   ThemeMode themeMode = cardoteka.get(SettingsCards.themeMode); // will return default value
///   await cardoteka.set<ThemeMode>(SettingsCards.themeMode, ThemeMode.light);
///   themeMode = cardoteka.get(SettingsCards.themeMode); // ThemeMode.light
///
///   DateTime? lastLoginTime = cardoteka.getOrNull(SettingsCards.lastLoginTime); // null
///   await cardoteka.setOrNull<DateTime>(SettingsCards.lastLoginTime, DateTime.now());
///   lastLoginTime = cardoteka.getOrNull(SettingsCards.lastLoginTime); // will return the saved time
///
///   cardoteka.getStoredCards(); // {SettingsCards.themeMode, SettingsCards.lastLoginTime}
///
///   await cardoteka.remove(SettingsCards.userColor); // nothing will happen
///   await cardoteka.remove(SettingsCards.lastLoginTime); // lastLoginTime removed from storage
///   cardoteka.getStoredEntries(); // {SettingsCards.themeMode: ThemeMode.light}
///
///   await cardoteka.removeAll();
///   cardoteka.getStoredCards(); // {}
/// }
/// ```
base class Cardoteka extends CardotekaCore {
  /// {@macro cardoteka.CardotekaCore.constructor}
  /// and create an instance of the [Cardoteka].
  Cardoteka({
    required super.config,
    required CardotekaStorage storage,
  }) : _storage = storage;

  final CardotekaStorage _storage;

  @override
  V? get<V extends Object?>(Card<V> card) {
    return getValueFromStorage<V>(card);
  }

  @override
  V getOrDefault<V extends Object?>(Card<V> card) {
    return getValueFromStorage<V>(card) ?? card.defaultValue;
  }

  @internal
  @protected
  @override
  V? getValueFromStorage<V extends Object?>(Card<V> card) {
    final Object? object = getObjectFromStorage(card.key, card.dartType);

    if (object == null) {
      return null;
    } else {
      return (getConverter(card)?.from(object) ?? object) as V?;
    }
  }

  @internal
  @protected
  @override
  Object? getObjectFromStorage(String key, DataType type) {
    return _storage.get(key, type);
  }

  @override
  void set<V extends Object?>(Card<V> card, V value) {
    // action will happen synchronously
    // ignore: discarded_futures
    super.set<V>(card, value);
  }

  @internal
  @protected
  @override
  void setValueToStorage<V extends Object?>(
    Card<V> card,
    V value,
  ) {
    final resultValue = getConverter(card)?.to(value) ?? value;
    _storage.set(card.key, resultValue, card.dartType) as V;
  }

  @override
  @protected
  void setObjectToStorage<V extends Object>(
    String key,
    V? value,
  ) {
    // action will happen synchronously
    // ignore: discarded_futures
    _storage.set<V>(
      key,
      value,
      value != null ? DataType.typeBy<V>(value) : null,
    );
  }

  // todo(03.03.2026, @PackRuble): put the same methods in the base class
  @override
  void remove(Card card) {
    watcher?.notifyAboutRemove([card]);
    // action will happen synchronously
    // ignore: discarded_futures
    _storage.remove(card.key);
  }

  @override
  void removeAll() {
    watcher?.notifyAboutRemove(cards);
    // action will happen synchronously
    // ignore: discarded_futures
    _storage.clear();
  }

  @override
  bool containsCard(Card card) {
    return _storage.containsKey(card.key) as bool;
  }

  @override
  Set<Card> getStoredCards() {
    final resultKeys = <Card>{
      for (final card in cards)
        if ((_storage.getKeys() as Set).cast<String>().contains(card.key)) card
    };

    return resultKeys;
  }

  @override
  Map<Card, Object> getStoredEntries() {
    return {
      for (final Card card in getStoredCards())
        card: getValueFromStorage<Object?>(card)!
    };
  }

  @override
  void reloadCache() {
    // action will happen synchronously
    // ignore: discarded_futures
    _storage.reloadCache();

    if (watcher != null) {
      final storedCards = getStoredCards();
      final mayHaveBeenRemoved = cards.toSet().difference(storedCards);
      watcher?.notifyAboutRemove(mayHaveBeenRemoved.toList());
      watcher?.notifyAll();
    }
  }
}
