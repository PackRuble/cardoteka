import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:reactive_db/src/custom_converters.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'converter.dart';
import 'i_rkey.dart';
import 'i_watcher.dart';

/// Global Todo:
///  1. Реализовать мигратор
///  2. Добавить больше поддерживаемых типов для сохранения (Color, Enum, ...)
///  3. Подумать о написании правильных тестов.
///  4. Понять, правильно ли работает изначальная синхронизация [RDatabase]
///  5. Добавить TypeSaved.custom и добавить возможность указать там свои forBd, Tobd

class RDatabase {
  RDatabase() {
    // todo: добавить метод асинхронной прогрузки базы данных
    // с учетом отслеживания текущего статуса (если будет запущено повторно)
  }

  /// List of keys for accessing the database.
  late final List<RKey> _rKeys;

  late final SharedPreferences _prefs;

  bool _isInitialized = false;

  /// Specify if listeners should be notified of new values in the database.
  @internal
  IWatcher? get watcher => null;

  // todo: Implement
  /// Specify if the keys are to be overwritten.
  /// Map<oldKey, newKey>
  Map<RKey, RKey>? migrator;

  /// Provide a converter for complex objects
  late final Map<RKey, RConverter>? _converters;

  /// Indicates whether the database is initialized.
  ///
  /// If it returns true, you can start making queries.
  bool get isInitialized => _isInitialized;

  /// Initialization [RDatabase]. You must provide keys of type [RKey].
  Future<RDatabase> init(
    List<RKey> rKeys, {
    Map<RKey, RConverter>? converters,
  }) async {
    if (!_isInitialized) {
      _rKeys = rKeys;
      if (converters != null) _converters = {}..addAll(converters);
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }

    return this;
  }

  /// Get [RDatabase] instance synchronously. It's a plug. !!! For further use of
  /// this class it is necessary to execute with waiting [init].
  ///
  /// Check the [RDatabase] initialization with [isInitialized].
  RDatabase initSync() => this;

  /// Returns Map{key: value} of all stored values from [SharedPreferences].
  Map<String, dynamic> getSavedData() {
    final Map<String, dynamic> result = {};

    for (final RKey rKey in _rKeys) {
      result.addAll({rKey.key: _getValueFromDb(rKey)});
    }

    return result;
  }

  // todo what return when [from(OurStoreKey.values)]
  /// Получить все ключи.
  Set<String> getAllKeys<T>() => Set<String>.from(_rKeys.map(_getKeyForDb));

  // todo это может быть необязательным?
  // Todo: в будущем может понадобиться указывать версию ключа.
  //  + необходим обратный способ конвертирования ключа.
  /// Get the key to use it in the [SharedPreferences].
  String _getKeyForDb(RKey rKey) => 'rKey_${rKey.key}';

  // todo: need?
  //  String _getKeyForDbPattern(String suffix, String key, String prefix) => '$suffix$key$prefix';

  /// Get value from [SharedPreferences] using key type [RKey].
  /// (!) You don't have to specify a generic type.
  ///
  /// The default behavior assumes that if [SharedPreferences] does not have
  /// a record with the provided key, then `defaultValue` will be returned.
  ///
  /// You can specify [ifAbsent] if you want to return your value
  /// instead of [defaultValue] in case the key is absent in the database.
  ///
  /// There will be a nice bonus as the type will be output depending on the
  /// return type [ifAbsent].
  ///
  T get<T>(RKey<T> rKey, [T Function()? ifAbsent]) {
    final T? value = _getValueFromDb<T>(rKey);

    if (value == null && ifAbsent != null) return ifAbsent.call();
    return value ?? rKey.defaultValue;
  }

  /// Save the new value in [SharedPreferences] using a key of type [RKey].
  /// (!) Always specify the generic type!
  ///
  /// [value] cannot be `null`.
  Future<bool> set<T extends Object>(RKey<T> rKey, T value) async {
    if (watcher != null) {
      watcher?.actualizeValue<T>(rKey, value);
    }

    return _setValueToDb<T>(rKey, value);
  }

  /// Internal method to retrieve data from [SharedPreferences].
  T? _getValueFromDb<T>(RKey<T> rKey) {
    final key = _getKeyForDb(rKey);

    final Object? value = () {
      switch (rKey.type) {
        case TypeSaved.bool:
          return _prefs.getBool;
        case TypeSaved.int:
          return _prefs.getInt;
        case TypeSaved.double:
          return _prefs.getDouble;
        case TypeSaved.string:
          return _prefs.getString;
        case TypeSaved.stringList:
          return _prefs.getStringList;
        case TypeSaved.color:
          return (String key) {
            final value = _prefs.getString(key);
            if (value != null) return const ColorConverter().fromDb(value);
          };
      }
    }()
        .call(key);

    if (value == null) {
      return value as T?;
    } else {
      final RConverter? converter = _converters?[rKey];

      return (converter?.fromDb(value) ?? value) as T?;
    }
  }

  /// Internal method to save data in [SharedPreferences].
  Future<bool> _setValueToDb<T extends Object>(RKey<T> rKey, T value) async {
    final key = _getKeyForDb(rKey);

    final RConverter? converter = _converters?[rKey];
    final raw = converter?.toDb(value);

    // todo: узнать, что возвращает конкретно вызов set?
    switch (rKey.type) {
      case TypeSaved.bool:
        return _prefs.setBool(key, (raw ?? value) as bool);
      case TypeSaved.int:
        return _prefs.setInt(key, (raw ?? value) as int);
      case TypeSaved.double:
        return _prefs.setDouble(key, (raw ?? value) as double);
      case TypeSaved.string:
        return _prefs.setString(key, (raw ?? value) as String);
      case TypeSaved.stringList:
        return _prefs.setStringList(key, (raw ?? value) as List<String>);
      case TypeSaved.color:
        final converted = const ColorConverter().toDb(value as Color);
        return _prefs.setString(key, converted);
    }
  }

  /// Provides the [SharedPreferences.remove] method of the same name.
  ///
  /// Copy:
  /// Removes an entry from persistent storage.
  ///
  Future<bool> remove(RKey rKey) async => _prefs.remove(_getKeyForDb(rKey));

  /// Provides the [SharedPreferences.reload] method of the same name.
  ///
  /// Copy:
  /// Fetches the latest values from the host platform.
  /// Use this method to observe modifications that were made in native code
  /// (without using the plugin) while the app is running.
  ///
  Future<void> reload() async => _prefs.reload();

  /// Provides the [SharedPreferences.clear] method of the same name.
  ///
  /// Copy:
  /// Completes with true once the user preferences for the app has been cleared.
  ///
  Future<bool> clear() async => _prefs.clear();

  /// Provides the [SharedPreferences.getKeys] method of the same name.
  ///
  /// Copy:
  /// Returns all keys in the persistent storage.
  ///
  Future<Set<String>> getAllSavedKeys() async => _prefs.getKeys();

  /// Provides the [SharedPreferences.containsKey] method of the same name.
  ///
  /// Copy:
  /// Returns true if persistent storage the contains the given key.
  ///
  Future<bool> containsKey(RKey rKey) async =>
      _prefs.containsKey(_getKeyForDb(rKey));
}
