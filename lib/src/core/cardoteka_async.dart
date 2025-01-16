import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesAsync;

import '../card.dart';
import 'cardoteka_core.dart';

/// Asynchronous implementation of a Cardoteka representing a wrapper over [SharedPreferencesAsync].
///
/// {@macro cardoteka.CardotekaCore}
///
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
  CardotekaAsync({required super.config});

  /// A reference to an instance of [SharedPreferencesAsync] from the package
  /// [shared_preferences](https://pub.dev/packages/shared_preferences)
  ///
  /// No initialization required.
  ///
  /// If you need to access this instance, use
  /// the 'package:cardoteka/access_to_sp.dart' import.
  /// This can also be useful in cases of gradual migration or quick testing
  /// of some hypotheses.
  static final _prefsAsync = SharedPreferencesAsync();

  /// {@macro cardoteka.CardotekaCore.get}
  ///
  /// Works similarly to the [SharedPreferencesAsync.getBool] method and
  /// others of the same name.
  @override
  Future<V> get<V extends Object>(Card<V> card) async =>
      await getValueFromStorage<V>(card) ?? card.defaultValue;

  @override
  Future<V?> getOrNull<V extends Object?>(Card<V?> card) async =>
      getValueFromStorage<V>(card);

  @internal
  @protected
  @override
  Future<V?> getValueFromStorage<V>(Card<V?> card) async {
    final key = getStorageKey(card);
    final Object? object = await switch (card.type) {
      DataType.string => _prefsAsync.getString(key),
      DataType.int => _prefsAsync.getInt(key),
      DataType.double => _prefsAsync.getDouble(key),
      DataType.bool => _prefsAsync.getBool(key),
      DataType.stringList => _prefsAsync.getStringList(key),
    };

    if (object == null) {
      // value was not in storage
      return object as V?;
    } else {
      return (getConverter(card)?.from(object) ?? object) as V?;
    }
  }

  /// {@macro cardoteka.CardotekaCore.set}
  ///
  /// Works similarly to the [SharedPreferencesAsync.setBool] method and
  /// others of the same name.
  @override
  Future<bool> set<V extends Object>(Card<V?> card, V value) async {
    watcher?.notify<V?>(card, value);

    return setValueToStorage<V>(card, value);
  }

  @internal
  @protected
  @override
  Future<bool> setValueToStorage<V extends Object>(
    Card<V?> card,
    V value,
  ) async {
    final resultValue = getConverter(card)?.to(value) ?? value;
    final key = getStorageKey(card);
    await switch (card.type) {
      DataType.bool => _prefsAsync.setBool(key, resultValue as bool),
      DataType.int => _prefsAsync.setInt(key, resultValue as int),
      DataType.double => _prefsAsync.setDouble(key, resultValue as double),
      DataType.string => _prefsAsync.setString(key, resultValue as String),
      DataType.stringList =>
        _prefsAsync.setStringList(key, (resultValue as List).cast<String>())
    };
    // fixdep(16.01.2025): [The methods for removing and setting values return bool, but this is a fiction (always return `true`) · Issue #32 · PackRuble/cardoteka](https://github.com/PackRuble/cardoteka/issues/32)
    return true;
  }

  /// {@macro cardoteka.CardotekaCore.remove}
  ///
  /// Works similarly to the [SharedPreferencesAsync.remove] method of the same name.
  @override
  Future<bool> remove(Card card) async {
    watcher?.notify(card, null);

    await _prefsAsync.remove(getStorageKey(card));
    // fixdep(16.01.2025): [The methods for removing and setting values return bool, but this is a fiction (always return `true`) · Issue #32 · PackRuble/cardoteka](https://github.com/PackRuble/cardoteka/issues/32)
    return true;
  }

  /// {@macro cardoteka.CardotekaCore.containsCard}
  ///
  /// Works similarly to the [SharedPreferencesAsync.containsKey] method of the same name.
  @override
  Future<bool> containsCard(Card card) async =>
      _prefsAsync.containsKey(getStorageKey(card));

  /// {@macro cardoteka.CardotekaCore.getStoredCards}
  ///
  /// Works similarly to the [SharedPreferencesAsync.getKeys] method of the same name.
  @override
  Future<Set<Card>> getStoredCards() async {
    final Set<String> storedKeys = await _prefsAsync.getKeys(
      // todo(22.12.2024):
      allowList: null,
    );
    final resultKeys = <Card>{
      for (final card in cards)
        if (storedKeys.contains(getStorageKey(card))) card
    };

    return resultKeys;
  }

  /// {@macro cardoteka.CardotekaCore.getStoredCards}
  ///
  /// Works similarly to the [SharedPreferencesAsync.getAll] method of the same name.
  @override
  Future<Map<Card, Object>> getStoredEntries() async {
    return {
      for (final card in await getStoredCards())
        card: (await getValueFromStorage(card))!
    };
  }
}
