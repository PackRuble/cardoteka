import 'dart:async';

import '../../card.dart' show DataType;

abstract interface class CardotekaStorageAsync {
  const CardotekaStorageAsync();

  /// If [onlyKeys]=null then everything except [exceptKeys] will be returned.
  ///
  /// If [onlyKeys]=non-null then all specified [onlyKeys]
  /// except [exceptKeys] will be returned.
  Future<Set<String>> getKeys({
    Set<String>? onlyKeys,
    Set<String>? exceptKeys,
  });

  Future<Map<String, dynamic>> getAll({
    Set<String>? onlyKeys,
    Set<String>? exceptKeys,
  });

  Future<T?> get<T extends Object>(String key, DataType<T> type);

  Future<void> set<T extends Object>(String key, T? value, DataType<T> type);

  Future<bool> containsKey(String key);

  Future<void> remove(String key);

  /// If [onlyKeys]=null, then the entire storage will be cleared.
  Future<void> clear({Set<String>? onlyKeys});
}
