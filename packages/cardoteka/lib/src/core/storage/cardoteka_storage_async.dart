import 'dart:async';

import 'storage_config.dart';

abstract class CardotekaStorageAsync {
  const CardotekaStorageAsync(this.config);

  final StorageConfig config;

  Future<bool> containsKey(String key);

  Future<Set<String>> getKeys({Set<String>? allowList});

  Future<Map<String, Object?>> getAll({Set<String>? allowList});

  Future<bool?> getBool(String key);

  Future<int?> getInt(String key);

  Future<double?> getDouble(String key);

  Future<String?> getString(String key);

  Future<List<String>?> getStringList(String key);

  Future<void> setBool(String key, bool value);

  Future<void> setInt(String key, int value);

  Future<void> setDouble(String key, double value);

  Future<void> setString(String key, String value);

  Future<void> setStringList(String key, List<String> value);

  Future<void> remove(String key);

  Future<void> clear();
}
