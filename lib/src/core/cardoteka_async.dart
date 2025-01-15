import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesAsync;

import '../card.dart';
import 'cardoteka_core.dart';

base class CardotekaAsync extends CardotekaCore {
  CardotekaAsync({required super.config});

  static final _prefsAsync = SharedPreferencesAsync();

  /// Get value from [SharedPreferencesAsync] storage using [Card]<[Object]>.
  ///
  /// The default behavior assumes that if [SharedPreferencesAsync] does not have
  /// a record with the provided card, then `defaultValue` will be returned.
  ///
  /// The returned object is always non-nullable.
  ///
  /// If you need to return a null-value when there is no record in storage
  ///   OR
  /// your card is of nullable type [Card]<[Object?]>,
  ///   then use the [getOrNull] method.
  @override
  Future<V> get<V extends Object>(Card<V> card) async {
    return await getValueFromSP<V>(card) ?? card.defaultValue;
  }

  /// Get value from [SharedPreferencesAsync] storage using [Card]<[Object?]>.
  ///
  /// If the record was not in the storage, then null will be returned. If you
  /// need to return a default value [Card.defaultValue] when there is no record
  /// in storage, use the [get] method.
  @override
  Future<V?> getOrNull<V extends Object?>(Card<V?> card) =>
      getValueFromSP<V>(card);

  /// Internal method to retrieve data from [SharedPreferencesAsync].
  @override
  Future<V?> getValueFromSP<V>(Card<V?> card) async {
    final key = keyForSP(card);

    final Object? value = await switch (card.type) {
      DataType.string => _prefsAsync.getString(key),
      DataType.int => _prefsAsync.getInt(key),
      DataType.double => _prefsAsync.getDouble(key),
      DataType.bool => _prefsAsync.getBool(key),
      DataType.stringList => _prefsAsync.getStringList(key),
    };

    if (value == null) {
      // value was not in the storage
      return value as V?;
    } else {
      return (getConverter(card)?.from(value) ?? value) as V?;
    }
  }

  /// Save the new value in [SharedPreferencesAsync] using [Card].
  ///
  /// NOTE: Always specify a generic type and do so according to the type
  /// of your [Card.defaultValue]. This will help prevent compilation errors
  /// because without specifying a generic type, a type will be output
  /// based on the [card] provided and the stored [value].
  ///
  /// What you need to know:
  /// - type of [card] and [value] must match.
  /// - [value] cannot be `null`. Use [setOrNull] when you want if you want
  /// to simulate storing null.
  /// - [watcher] will be notified anyway (if it is not null).
  ///
  /// If successful, it will return true.
  @override
  Future<bool> set<V extends Object>(Card<V?> card, V value) async {
    watcher?.notify<V?>(card, value);

    return setValueToSP<V>(card, value);
  }

  /// Internal method to save data in [SharedPreferencesAsync].
  ///
  /// Returns true if the value was successfully saved.
  @override
  Future<bool> setValueToSP<V extends Object>(Card<V?> card, V value) async {
    final resultValue = getConverter(card)?.to(value) ?? value;
    final key = keyForSP(card);
    await switch (card.type) {
      DataType.bool => _prefsAsync.setBool(key, resultValue as bool),
      DataType.int => _prefsAsync.setInt(key, resultValue as int),
      DataType.double => _prefsAsync.setDouble(key, resultValue as double),
      DataType.string => _prefsAsync.setString(key, resultValue as String),
      DataType.stringList =>
        _prefsAsync.setStringList(key, (resultValue as List).cast<String>())
    };
    // todo(22.12.2024): имитация успеха
    return true;
  }

  /// Removes an entry by using [card] from persistent storage.
  /// The [watcher] will be notified anyway (if it is not null).
  ///
  /// If successful, it will return true.
  ///
  /// Works similarly to the [SharedPreferencesAsync.remove] method of the same name.
  @override
  Future<bool> remove(Card card) async {
    await super.remove(card);

    await _prefsAsync.remove(keyForSP(card));
    // todo(22.12.2024): имитация успеха
    return true;
  }

  /// Returns all [cards] that contains in the persistent storage.
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
        if (storedKeys.contains(keyForSP(card))) card
    };

    return resultKeys;
  }

  /// Returns true if persistent storage the contains the given [card].
  ///
  /// Works similarly to the [SharedPreferencesAsync.containsKey] method of the same name.
  @override
  Future<bool> containsCard(Card card) async =>
      _prefsAsync.containsKey(keyForSP(card));

  /// Returns all stored entities from the persistent storage.
  ///
  /// Works similarly to the [AccessToSP.getEntries] method of the same name.
  @override
  Future<Map<Card, Object>> getStoredEntries() async {
    return {
      // todo(22.12.2024): use getAll method
      for (final Card card in await getStoredCards())
        card: (await getValueFromSP(card))!
    };
  }
}
