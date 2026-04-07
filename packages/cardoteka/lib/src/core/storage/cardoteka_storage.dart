import 'dart:async' show FutureOr;

import '../../data_type.dart';

abstract interface class CardotekaStorage {
  const CardotekaStorage();

  /// If [onlyKeys]=null then everything except [exceptKeys] will be returned.
  ///
  /// If [onlyKeys]=non-null then all specified [onlyKeys]
  /// except [exceptKeys] will be returned.
  FutureOr<Set<String>> getKeys({
    Set<String>? onlyKeys,
    Set<String>? exceptKeys,
  });

  FutureOr<Map<String, dynamic>> getAll({
    Set<String>? onlyKeys,
    Set<String>? exceptKeys,
  });

  FutureOr<V?> get<V extends Object>(String key, DataType<V> type);

  // is required to explicitly specify that the method to be implemented can be
  // either synchronous or asynchronous, while returning void
  // ignore_for_file: avoid_futureor_void
  FutureOr<void> set<V extends Object>(String key, V? value, DataType<V>? type);

  FutureOr<bool> containsKey(String key);

  FutureOr<void> remove(String key);

  /// If [onlyKeys]=null, then the entire storage will be cleared.
  FutureOr<void> clear({Set<String>? onlyKeys});

  // todo(21.02.2026, @PackRuble): add return changes if there were
  FutureOr<void> reloadCache();
}
