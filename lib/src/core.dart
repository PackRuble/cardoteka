import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:reactive_db/src/custom_converters.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config_db.dart';
import 'converter.dart';
import 'core_debug.dart';
import 'i_card.dart';
import 'i_watcher.dart';

/// Global Todo:
/// 1. Implement a migrator
/// 2. Add more supported types for saving (Color, Enum, ...)
/// 3. Think about writing the right tests.

/// A handy wrapper for typed use [SharedPreferences].
class CardDb {
  const CardDb({
    required this.cards,
    required ConfigDB config,
  }) : _config = config;

  /// List of keys [ICard] for accessing the database [SharedPreferences].
  final List<ICard> cards;

  /// Configuration file.
  final ConfigDB _config;

  static late final SharedPreferences _prefs;

  /// Specify if listeners should be notified of new values in the database.
  ///
  /// Use a mixin based on the [IWatcher] interface.
  @internal
  IWatcher? get watcher => null;

  /// Indicates whether the database is initialized. Use the [init] method to
  /// initialize and wait for it to complete.
  ///
  /// If it returns true, you can start making queries.
  bool get isInitialized => _isInitialized;

  static bool _isInitialized = false;

  /// Initialization [CardDb]. It is necessary to wait for completion.
  Future<bool> init() async {
    if (!_isInitialized) {
      assert(checkConfiguration(cards: cards, config: _config));

      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }

    return true;
  }

  // /// Get the key after [SharedPreferences].
  // String _getKeyFromDb(String key) => key.split(_separatorKey)[1];

  /// Get the key to use it in the [SharedPreferences].
  String _keyForSP(ICard card) => '${_config.name}.${card.key}';

  /// Get value from [SharedPreferences] using key type [ICard].
  ///
  /// The default behavior assumes that if [SharedPreferences] does not have
  /// a record with the provided key, then `defaultValue` will be returned.
  ///
  /// The returned object is always non-nullable.
  T get<T extends Object>(ICard<T> storeCard) {
    checkInit(_isInitialized);

    return _getValueFromDb<T>(storeCard) ?? storeCard.defaultValue;
  }

  /// The return null will mean there is no value in the db [SharedPreferences].
  ///
  /// [ICard.defaultValue] is not used in this case.
  T? getOrNull<T extends Object?>(ICard<T?> storeCard) {
    checkInit(_isInitialized);

    return _getValueFromDb<T>(storeCard);
  }

  /// Internal method to retrieve data from [SharedPreferences].
  T? _getValueFromDb<T>(ICard<T?> card) {
    final key = _keyForSP(card);

    final Object? value = () {
      switch (card.type) {
        case TypeData.bool:
          return _prefs.getBool;
        case TypeData.int:
          return _prefs.getInt;
        case TypeData.double:
          return _prefs.getDouble;
        case TypeData.string:
          return _prefs.getString;
        case TypeData.stringList:
          return _prefs.getStringList;
        case TypeData.color:
          return (String key) {
            final value = _prefs.getString(key);
            if (value != null) return const ColorConverter().fromDb(value);
          };
      }
    }.call().call(key);

    if (value == null) {
      return value as T?;
    } else {
      final IConverter? converter = _config.converters?[card];
      return (converter?.fromDb(value) ?? value) as T?;
    }
  }

  /// Save the new value in [SharedPreferences] using a key of type [ICard].
  /// (!Note!) Always specify the generic type and do so according to [ICard.type]
  ///
  /// [value] cannot be `null`.
  ///
  /// All [watcher]s will be notified.
  Future<bool> set<T extends Object>(ICard<T?> storeCard, T value) async {
    checkInit(_isInitialized);

    watcher?.notify<T>(storeCard, value);

    return _setValueToDb<T>(storeCard, value);
  }

  /// Save the new value in [SharedPreferences] using [storeCard] if ([value] != null).
  /// Otherwise the value will be deleted from the database to simulate null.
  ///
  /// All [watcher]s will be notified anyway.
  Future<bool?> setIfNotNull<T extends Object>(
    ICard<T?> storeCard,
    T? value,
  ) async {
    checkInit(_isInitialized);

    watcher?.notify<T>(storeCard, value);

    if (value == null
        // && value is! T
        ) {
      await remove(storeCard);
      return null;
    }

    return _setValueToDb<T>(storeCard, value);
  }

  /// Internal method to save data in [SharedPreferences].
  ///
  /// Returns true if the value was successfully saved.
  Future<bool> _setValueToDb<T extends Object>(ICard<T?> card, T value) async {
    final key = _keyForSP(card);

    final resultValue = _getConverter(card)?.toDb(value) ?? value;

    // optimize: use a pre-made map?
    switch (card.type) {
      case DataType.bool:
        return _prefs.setBool(key, resultValue as bool);
      case DataType.int:
        return _prefs.setInt(key, resultValue as int);
      case DataType.double:
        return _prefs.setDouble(key, resultValue as double);
      case DataType.string:
        return _prefs.setString(key, resultValue as String);
      case DataType.stringList:
        return _prefs.setStringList(key, (resultValue as List).cast<String>());
    }
  }

  IConverter? _getConverter(ICard card) {
    final Map<ICard, IConverter>? converters = _config.converters;
    if (converters != null) {
      if (converters.containsKey(card)) {
        return converters[card]!;
      }
    }
    return null;
  }

  /// Acts according to the [SharedPreferences.remove] method of the same name.
  /// Removes an entry by using [card] from persistent storage.
  ///
  /// If successful, it will return true.
  Future<bool> remove(ICard card) async {
    checkInit(_isInitialized);

    return _prefs.remove(_keyForSP(card));
  }

  /// Acts according to the [SharedPreferences.clear] method of the same name.
  ///
  /// Iteratively removes all values associated with the provided [cards]
  /// from persistent storage.
  ///
  /// Returns true if the operation was successful.
  ///
  Future<bool> removeAll() async {
    for (final card in cards) {
      await remove(card);
    }

    return true;
  }

  /// Acts according to the [SharedPreferences.getKeys] method of the same name.
  ///
  /// Returns all [cards] that contains in the persistent storage.
  Set<ICard> getCards() {
    checkInit(_isInitialized);

    final Set<String> allStoredKey = _prefs.getKeys();
    final resultKeys = <ICard>{
      for (final card in cards)
        if (allStoredKey.contains(_keyForSP(card))) card
    };

    return resultKeys;
  }

  /// Returns true if persistent storage the contains the given [card].
  Future<bool> containsCard(ICard card) async {
    checkInit(_isInitialized);

    return _prefs.containsKey(_keyForSP(card));
  }

  Future<T> _convertValueToDb<T extends Object>(
    ICard<T?> card,
    Object value,
  ) async {
    final IConverter? converter = _config.converters?[card];
    final Object? convertedValue = converter?.toDb(value);

    final Object result = convertedValue ?? value;

    switch (card.type) {
      case TypeData.bool:
        return (result as bool) as T;
      case TypeData.int:
        return (result as int) as T;
      case TypeData.double:
        return (result as double) as T;
      case TypeData.string:
        return (result as String) as T;
      case TypeData.stringList:
        return ((result as List).cast<String>()) as T;
      case TypeData.color:
        final converted = const ColorConverter().toDb(value as Color);
        return converted as T;
    }
  }

  /// Acts according to the [SharedPreferences.setMockInitialValues] method of the same name.
  @visibleForTesting
  void setMockInitialValues(Map<ICard, Object> values) {
    assert(checkConfiguration(cards: cards, config: _config));

    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({
      for (final MapEntry<ICard<Object?>, Object> entry in values.entries)
        _keyForSP(entry.key): _convertValueToDb(entry.key, entry.value)
    });
  }

  /// Acts according to the [AccessToSP.getEntries] method of the same name.
  ///
  /// Returns all stored entities from the persistent storage.
  Map<ICard, Object> getStoredEntries() {
    checkInit(_isInitialized);

    return {for (final ICard card in getCards()) card: _getValueFromDb(card)!};
  }
}

/// Get access to all the original methods of the [SharedPreferences] library.
///
/// Sometimes can be useful for debugging or for use outside the system [CardDb].
mixin AccessToSP on CardDb {
  SharedPreferences get prefs {
    checkInit(CardDb._isInitialized);

    return CardDb._prefs;
  }

  /// The original [SharedPreferences.setPrefix] method.
  static void setPrefix(String prefix) => SharedPreferences.setPrefix(prefix);

  /// The original [SharedPreferences.resetStatic] method.
  @visibleForTesting
  // ignore: invalid_use_of_visible_for_testing_member
  static void resetStatic() => SharedPreferences.resetStatic();

  /// The original [SharedPreferences.getInstance] method.
  ///
  /// Useful in tests after call [SharedPreferences.setMockInitialValues].
  @visibleForTesting
  static Future<void> reInit() async {
    CardDb._prefs = await SharedPreferences.getInstance();
  }

  /// Returns all entries (key: value) in the persistent storage.
  Map<String, Object> getEntries() =>
      {for (final key in prefs.getKeys()) key: prefs.get(key)!};
}
