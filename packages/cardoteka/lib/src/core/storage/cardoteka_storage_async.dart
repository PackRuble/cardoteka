import 'dart:async';

import '../../card.dart';

abstract interface class CardotekaStorageAsync {
  const CardotekaStorageAsync();

  Future<Set<String>> getKeys({
    Set<String>? allowKeys,
    Set<String>? ignoreKeys,
  });

  Future<Map<String, Object?>> getAll({
    Set<String>? allowKeys,
    Set<String>? ignoreKeys,
  });

  Future<T?> get<T extends Object>(String key, DataType<T> type);

  Future<void> set<T extends Object>(String key, T? value, DataType<T> type);

  Future<bool> containsKey(String key);

  Future<void> remove(String key);

  Future<void> clear({
    Set<String>? allowKeys,
    Set<String>? ignoreKeys,
  });
}
