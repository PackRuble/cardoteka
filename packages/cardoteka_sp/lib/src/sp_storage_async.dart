import 'dart:async';

import 'package:cardoteka/cardoteka.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesAsync;

// todo(21.02.2026, @PackRuble): add card prefix

/// A wrapper around the `shared_preferences` package that turns
/// [SharedPreferencesAsync] into an instance of [CardotekaStorage] for
/// further work with `Cardoteka`.
class SpStorageAsync implements CardotekaStorage {
  const SpStorageAsync();

  /// A reference to an instance of [SharedPreferencesAsync] from the package
  /// [shared_preferences](https://pub.dev/packages/shared_preferences)
  ///
  /// No initialization required.
  static final _prefsAsync = SharedPreferencesAsync();

  /// Works similarly to the [SharedPreferencesAsync.getKeys] method of the same name.
  @override
  Future<Set<String>> getKeys({
    Set<String>? onlyKeys,
    Set<String>? exceptKeys,
  }) async {
    final keys = onlyKeys?.difference(exceptKeys ?? {});

    Set<String> result;
    result = await _prefsAsync.getKeys(allowList: keys);

    if (keys == null && exceptKeys != null) {
      result = result.difference(exceptKeys);
    }

    return result;
  }

  /// Works similarly to the [SharedPreferencesAsync.getAll] method of the same
  /// name.
  @override
  Future<Map<String, dynamic>> getAll({
    Set<String>? onlyKeys,
    Set<String>? exceptKeys,
  }) async {
    final keys = onlyKeys?.difference(exceptKeys ?? {});

    Map<String, dynamic> data;
    data = await _prefsAsync.getAll(allowList: keys);

    if (keys == null && exceptKeys != null) {
      for (final key in exceptKeys) {
        data.remove(key);
      }
    }

    return data;
  }

  /// Works similarly to the [SharedPreferencesAsync].get* methods.
  @override
  Future<V?> get<V extends Object>(String key, DataType<V> type) async {
    final result = switch (type) {
      DataType.string => await _prefsAsync.getString(key),
      DataType.int => await _prefsAsync.getInt(key),
      DataType.double => await _prefsAsync.getDouble(key),
      DataType.bool => await _prefsAsync.getBool(key),
      DataType.list => await _prefsAsync.getStringList(key),
      DataType.object => (await _prefsAsync.getAll(allowList: {key}))[key],
      DataType.map => throw ArgumentError(
          'The shared_preferences does not support type=$type.',
        ),
    };
    return result as V?;
  }

  /// Works similarly to the [SharedPreferencesAsync].set* methods.
  @override
  Future<void> set<V extends Object>(
    String key,
    V? value,
    DataType<V>? type,
  ) async {
    if (value == null) {
      await remove(key);
    } else {
      await switch (type) {
        DataType.bool => _prefsAsync.setBool(key, value as bool),
        DataType.int => _prefsAsync.setInt(key, value as int),
        DataType.double => _prefsAsync.setDouble(key, value as double),
        DataType.string => _prefsAsync.setString(key, value as String),
        DataType.list =>
          _prefsAsync.setStringList(key, (value as List).cast<String>()),
        DataType.map || DataType.object || null => throw ArgumentError(
            'The shared_preferences does not support storing Object with type=$type.',
          ),
      };
    }
  }

  /// Works similarly to the [SharedPreferencesAsync.containsKey] method
  /// of the same name.
  @override
  Future<bool> containsKey(String key) async {
    return _prefsAsync.containsKey(key);
  }

  /// Works similarly to the [SharedPreferencesAsync.remove] method
  /// of the same name.
  @override
  Future<void> remove(String key) async {
    await _prefsAsync.remove(key);
  }

  /// Works similarly to the [SharedPreferencesAsync.clear] method
  /// of the same name.
  @override
  Future<void> clear({Set<String>? onlyKeys}) async {
    await _prefsAsync.clear(allowList: onlyKeys);
  }

  @override
  Future<void> reloadCache() async {}
}
