import 'dart:async';

import 'package:cardoteka/cardoteka.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesWithCache, SharedPreferencesWithCacheOptions;

class CardotekaSpSync implements CardotekaStorage {
  CardotekaSpSync(this.config);

  @override
  final StorageConfig config;

  static late SharedPreferencesWithCache _prefs;

  @override
  Future<CardotekaSpSync> create() async {
    _prefs = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(
        // we don't want to enumerate all the cards because then we need
        // to access them on a static basis
        // ignore: avoid_redundant_argument_values
        allowList: null,
      ),
    );
    return this;
  }

  @override
  Future<void> reloadCache() async {
    await _prefs.reloadCache();
  }

  @override
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  @override
  Set<String> get keys => _prefs.keys;

  @override
  Object? get(String key) {
    return _prefs.get(key);
  }

  @override
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  @override
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  @override
  double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  @override
  String? getString(String key) {
    return _prefs.getString(key);
  }

  @override
  List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  @override
  Future<void> setBool(String key, bool value) {
    return _prefs.setBool(key, value);
  }

  @override
  Future<void> setInt(String key, int value) {
    return _prefs.setInt(key, value);
  }

  @override
  Future<void> setDouble(String key, double value) {
    return _prefs.setDouble(key, value);
  }

  @override
  Future<void> setString(String key, String value) {
    return _prefs.setString(key, value);
  }

  @override
  Future<void> setStringList(String key, List<String> value) {
    return _prefs.setStringList(key, value);
  }

  @override
  Future<void> remove(String key) async {
    return _prefs.remove(key);
  }

  @override
  Future<void> clear() async {
    return _prefs.clear();
  }
}
