import '../../data_type.dart';
import 'cardoteka_storage.dart';

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
    return _data[key] as T?;
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

  @override
  void reloadCache() {}
}

class MemoryStorageAsync implements CardotekaStorage {
  MemoryStorageAsync({Map<String, dynamic>? initialData})
      : _storage = MemoryStorage(initialData: initialData);

  final MemoryStorage _storage;

  @override
  Future<Set<String>> getKeys({
    Set<String>? onlyKeys,
    Set<String>? exceptKeys,
  }) =>
      Future(
          () => _storage.getKeys(onlyKeys: onlyKeys, exceptKeys: exceptKeys));

  @override
  Future<Map<String, dynamic>> getAll({
    Set<String>? onlyKeys,
    Set<String>? exceptKeys,
  }) =>
      Future(() => _storage.getAll(onlyKeys: onlyKeys, exceptKeys: exceptKeys));

  @override
  Future<T?> get<T extends Object>(String key, DataType<T> type) =>
      Future(() => _storage.get(key, type));

  @override
  Future<void> set<T extends Object>(String key, T? value, DataType<T>? type) =>
      Future(() => _storage.set(key, value, type));

  @override
  Future<bool> containsKey(String key) =>
      Future(() => _storage.containsKey(key));

  @override
  Future<void> remove(String key) => Future(() => _storage.remove(key));

  @override
  Future<void> clear({Set<String>? onlyKeys}) => Future(_storage.clear);

  @override
  Future<void> reloadCache() => Future(_storage.reloadCache);
}
