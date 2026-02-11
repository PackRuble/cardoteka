import 'dart:async';

import 'package:cardoteka/cardoteka.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesAsync;

// todo(11.02.2026, @PackRuble): rename SpStorageAsync
class CardotekaSpAsync implements CardotekaStorageAsync {
  static final _prefsAsync = SharedPreferencesAsync();

  @override
  Future<Set<String>> getKeys({
    Set<String>? allowKeys,
    Set<String>? ignoreKeys,
  }) async {
    // todo(09.02.2026, @PackRuble): common assert allowKeys|ignoreKeys
    // todo(09.02.2026, @PackRuble): use ignoreKeys
    return _prefsAsync.getKeys(allowList: allowKeys);
  }

  @override
  Future<Map<String, Object?>> getAll({
    Set<String>? allowKeys,
    Set<String>? ignoreKeys,
  }) async {
    // todo(09.02.2026, @PackRuble): common assert allowKeys|ignoreKeys
    // todo(09.02.2026, @PackRuble): use ignoreKeys
    return _prefsAsync.getAll(allowList: allowKeys);
  }

  @override
  Future<T?> get<T extends Object>(String key, DataType<T> type) async {
    final result = await switch (type) {
      DataType.string => _prefsAsync.getString(key),
      DataType.int => _prefsAsync.getInt(key),
      DataType.double => _prefsAsync.getDouble(key),
      DataType.bool => _prefsAsync.getBool(key),
      DataType.stringList => _prefsAsync.getStringList(key),
    };
    return result as T?;
  }

  @override
  Future<void> set<T extends Object>(
    String key,
    T? value,
    DataType<T> type,
  ) async {
    await switch (type) {
      DataType.bool => _prefsAsync.setBool(key, value as bool),
      DataType.int => _prefsAsync.setInt(key, value as int),
      DataType.double => _prefsAsync.setDouble(key, value as double),
      DataType.string => _prefsAsync.setString(key, value as String),
      DataType.stringList =>
        _prefsAsync.setStringList(key, (value as List).cast<String>())
    };
  }

  @override
  Future<bool> containsKey(String key) async {
    return _prefsAsync.containsKey(key);
  }

  @override
  Future<void> remove(String key) async {
    await _prefsAsync.remove(key);
  }

  @override
  Future<void> clear({
    Set<String>? allowKeys,
    Set<String>? ignoreKeys,
  }) async {
    // todo(09.02.2026, @PackRuble): common assert allowKeys|ignoreKeys

    if (ignoreKeys != null) {
      final allKeys = await getKeys();
      allowKeys = allKeys.difference(ignoreKeys);
    }

    await _prefsAsync.clear(allowList: allowKeys);
  }
}
