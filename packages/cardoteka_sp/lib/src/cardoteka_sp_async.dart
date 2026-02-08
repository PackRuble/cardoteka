import 'dart:async';

import 'package:cardoteka/cardoteka.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesAsync;

class CardotekaSpAsync implements CardotekaStorageAsync {
  CardotekaSpAsync(this.config);

  @override
  final StorageConfig config;

  static final _prefsAsync = SharedPreferencesAsync();

  @override
  Future<Set<String>> getKeys({Set<String>? allowList}) async {
    return await _prefsAsync.getKeys(allowList: allowList);
  }

  @override
  Future<Map<String, Object?>> getAll({Set<String>? allowList}) async {
    return await _prefsAsync.getAll(allowList: allowList);
  }

  @override
  Future<bool?> getBool(String key) async {
    return await _prefsAsync.getBool(key);
  }

  @override
  Future<int?> getInt(String key) async {
    return await _prefsAsync.getInt(key);
  }

  @override
  Future<double?> getDouble(String key) async {
    return await _prefsAsync.getDouble(key);
  }

  @override
  Future<String?> getString(String key) async {
    return await _prefsAsync.getString(key);
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    return await _prefsAsync.getStringList(key);
  }

  @override
  Future<bool> containsKey(String key) async {
    return await _prefsAsync.containsKey(key);
  }

  @override
  Future<void> setBool(String key, bool value) async {
    await _prefsAsync.setBool(key, value);
  }

  @override
  Future<void> setInt(String key, int value) async {
    await _prefsAsync.setInt(key, value);
  }

  @override
  Future<void> setDouble(String key, double value) async {
    await _prefsAsync.setDouble(key, value);
  }

  @override
  Future<void> setString(String key, String value) async {
    await _prefsAsync.setString(key, value);
  }

  @override
  Future<void> setStringList(String key, List<String> value) async {
    await _prefsAsync.setStringList(key, value);
  }

  @override
  Future<void> remove(String key) async {
    await _prefsAsync.remove(key);
  }

  @override
  Future<void> clear({Set<String>? allowList}) async {
    await _prefsAsync.clear(allowList: allowList);
  }
}
