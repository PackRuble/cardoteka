import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:reactive_db/src/custom_converters.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'converter.dart';
import 'core_debug.dart';
import 'i_card.dart';
import 'i_watcher.dart';

/// Global Todo:
///  1. Реализовать мигратор
///  2. Добавить больше поддерживаемых типов для сохранения (Color, Enum, ...)
///  3. Подумать о написании правильных тестов.
///  4. Понять, правильно ли работает изначальная синхронизация [CardDb]
///  5. Добавить TypeSaved.custom и добавить возможность указать там свои forBd, Tobd

class CardDb {
  CardDb({required this.cards}) {
    debugCheckKeys(cards);
  }

  /// List of keys [ICard] for accessing the database [SharedPreferences].
  final List<ICard> cards;

  late final SharedPreferences _prefs;

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

  bool _isInitialized = false;

  /// Initialization [CardDb]. You must provide keys of type [ICard].
  Future<CardDb> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }

    return this;
  }

  /// Get [CardDb] instance synchronously. It's a plug. !!! For further use of
  /// this class it is necessary to execute with waiting [init].
  ///
  /// Check the [CardDb] initialization with [isInitialized].
  // CardDb initSync() => this;

  /// Returns Map{key: value} of all stored values from [SharedPreferences].
  Map<String, dynamic> getSavedData() {
    debugCheckInit(_isInitialized);

    final Map<String, dynamic> result = {};

    for (final ICard rKey in cards) {
      result.addAll({rKey.key: _getValueFromDb(rKey)});
    }

    return result;
  }

  // /// Get the key after [SharedPreferences].
  // String _getKeyFromDb(String key) => key.split(_separatorKey)[1];

  /// Get the key to use it in the [SharedPreferences].
  String _getKeyForDb(ICard card) => card.config.name + card.key;

  /// Get value from [SharedPreferences] using key type [ICard].
  ///
  /// The default behavior assumes that if [SharedPreferences] does not have
  /// a record with the provided key, then `defaultValue` will be returned.
  ///
  /// The returned object is always non-nullable.
  T get<T extends Object>(ICard<T> storeCard) {
    debugCheckInit(_isInitialized);

    return _getValueFromDb<T>(storeCard) ?? storeCard.defaultValue;
  }

  /// The return null will mean there is no value in the db [SharedPreferences].
  ///
  /// [ICard.defaultValue] is not used in this case.
  T? getOrNull<T extends Object?>(ICard<T?> storeCard) {
    debugCheckInit(_isInitialized);

    return _getValueFromDb<T>(storeCard);
  }

  /// Internal method to retrieve data from [SharedPreferences].
  T? _getValueFromDb<T>(ICard<T?> card) {
    debugCheckProvidedCustomConverter(card);

    final key = _getKeyForDb(card);

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
      final IConverter? converter = card.config.converters?[card];
      return (converter?.fromDb(value) ?? value) as T?;
    }
  }

  /// Save the new value in [SharedPreferences] using a key of type [ICard].
  /// (!Note!) Always specify the generic type and do so according to [ICard.type]
  ///
  /// [value] cannot be `null`.
  Future<bool> set<T extends Object>(ICard<T?> storeCard, T value) async {
    debugCheckInit(_isInitialized);

    watcher?.notify<T>(storeCard, value);

    return _setValueToDb<T>(storeCard, value);
  }

  /// Internal method to save data in [SharedPreferences].
  ///
  /// Returns true if the value was successfully saved.
  Future<bool> _setValueToDb<T extends Object>(ICard<T?> card, T value) async {
    debugCheckProvidedCustomConverter(card);

    final key = _getKeyForDb(card);

    final IConverter? converter = card.config.converters?[card];
    final Object? raw = converter?.toDb(value);

    switch (card.type) {
      case TypeData.bool:
        return _prefs.setBool(key, (raw ?? value) as bool);
      case TypeData.int:
        return _prefs.setInt(key, (raw ?? value) as int);
      case TypeData.double:
        return _prefs.setDouble(key, (raw ?? value) as double);
      case TypeData.string:
        return _prefs.setString(key, (raw ?? value) as String);
      case TypeData.stringList:
        return _prefs.setStringList(
            key, ((raw ?? value) as List).cast<String>());
      case TypeData.color:
        final converted = const ColorConverter().toDb(value as Color);
        return _prefs.setString(key, converted);
    }
  }

  /// Provides the [SharedPreferences.remove] method of the same name.
  ///
  /// Copy:
  /// Removes an entry from persistent storage.
  ///
  Future<bool> remove(ICard card) async {
    debugCheckInit(_isInitialized);

    return _prefs.remove(_getKeyForDb(card));
  }

  /// Iteratively removes all values associated with the provided keys [_listStoreCards]
  /// from the database.
  ///
  /// Returns true if the operation was successful.
  ///
  Future<bool> removeAll() async {
    for (final card in cards) {
      await remove(card);
    }

    return true;
  }

  /// Provides the [SharedPreferences.reload] method of the same name.
  ///
  /// Copy:
  /// Fetches the latest values from the host platform.
  /// Use this method to observe modifications that were made in native code
  /// (without using the plugin) while the app is running.
  ///
  Future<void> reload() async {
    debugCheckInit(_isInitialized);

    return _prefs.reload();
  }

  /// Provides the [SharedPreferences.clear] method of the same name.
  ///
  /// Copy:
  /// Completes with true once the user preferences for the app has been cleared.
  ///
  Future<bool> clear() async {
    debugCheckInit(_isInitialized);

    return _prefs.clear();
  }

  /// Provides the [SharedPreferences.getKeys] method of the same name.
  ///
  /// Copy:
  /// Returns all keys in the persistent storage.
  ///
  Future<Set<ICard>> getCards() async {
    debugCheckInit(_isInitialized);

    final Set<String> allStoredKey = _prefs.getKeys();
    final resultKeys = <ICard>{};

    for (final card in cards) {
      if (allStoredKey.contains(_getKeyForDb(card))) {
        resultKeys.add(card);
      }
    }

    return resultKeys;
  }

  /// Provides the [SharedPreferences.containsKey] method of the same name.
  ///
  /// Copy:
  /// Returns true if persistent storage the contains the given key.
  ///
  Future<bool> containsKey(ICard card) async {
    debugCheckInit(_isInitialized);

    return _prefs.containsKey(_getKeyForDb(card));
  }
}
