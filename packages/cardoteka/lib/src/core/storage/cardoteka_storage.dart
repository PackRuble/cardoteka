import 'dart:async' show FutureOr;

import 'package:meta/meta.dart' show internal, protected;

import '../../card.dart' show DataType;

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

  // todo(21.02.2026, @PackRuble):
  FutureOr<void> reloadCache();
}

class MemoryStorage implements CardotekaStorage {
  MemoryStorage({
    Map<String, dynamic>? initialData,
  }) : _data = initialData ?? {};

  final Map<String, dynamic> _data;

  @override
  Set<String> getKeys({
    Set<String>? onlyKeys,
    Set<String>? exceptKeys,
  }) {
    final all = getAll(onlyKeys: onlyKeys, exceptKeys: exceptKeys);

    return all.keys.toSet();
  }

  @override
  Map<String, dynamic> getAll({
    Set<String>? onlyKeys,
    Set<String>? exceptKeys,
  }) {
    Map<String, dynamic> result = {};

    if (onlyKeys == null) {
      if (exceptKeys == null) {
        result = _data;
      } else {
        for (final entry in _data.entries) {
          if (exceptKeys.contains(entry.key)) continue;
          if (!_data.containsKey(entry.key)) continue;

          result[entry.key] = _data[entry.key];
        }
      }
    } else {
      final keys = onlyKeys.difference(exceptKeys ?? {});

      for (final key in keys) {
        if (!_data.containsKey(key)) continue;

        result[key] = _data[key];
      }
    }

    return result;
  }

  @override
  T? get<T extends Object>(String key, DataType<T> type) {
    return type.cast(_data[key]);
  }

  @override
  void set<T extends Object>(String key, T? value, _) {
    _data[key] = value;
  }

  @override
  bool containsKey(String key) {
    final keys = getKeys(onlyKeys: {key});

    return keys.isNotEmpty;
  }

  @override
  void remove(String key) {
    _data.remove(key);
  }

  @override
  void clear({Set<String>? onlyKeys}) {
    if (onlyKeys == null) {
      _data.clear();
    } else {
      for (final key in onlyKeys) {
        _data.remove(key);
      }
    }
  }

  @internal
  @protected
  @override
  void reloadCache() {}
}
