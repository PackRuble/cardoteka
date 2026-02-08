import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cardoteka/cardoteka.dart';

class CardotekaJsonWithCache implements CardotekaStorage {
  CardotekaJsonWithCache(this.config) : _file = File(config.path!)..create();

  @override
  final StorageConfig config;

  final File _file;

  /// Cache containing in-memory data.
  final _cache = <String, Object?>{};

  Future<Map<String, dynamic>> get _data async {
    final data = await _file.readAsString();
    if (data.isEmpty) return {};
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> _save(Map<String, dynamic> data) async {
    await _file.writeAsString(jsonEncode(data));
  }

  @override
  Future<CardotekaJsonWithCache> create() async {
    await reloadCache();
    return this;
  }

  @override
  Future<void> reloadCache() async {
    _cache.clear();
    _cache.addAll(await _data);
  }

  @override
  bool containsKey(String key) {
    return _cache.containsKey(key);
  }

  @override
  Set<String> get keys => _cache.keys.toSet();

  @override
  Object? get(String key) {
    return _cache[key];
  }

  @override
  bool? getBool(String key) {
    return get(key) as bool?;
  }

  @override
  int? getInt(String key) {
    return get(key) as int?;
  }

  @override
  double? getDouble(String key) {
    return get(key) as double?;
  }

  @override
  String? getString(String key) {
    return get(key) as String?;
  }

  @override
  List<String>? getStringList(String key) {
    return (_cache[key] as List<Object?>?)?.cast<String>().toList();
  }

  Future<void> _set(String key, dynamic value) async {
    final data = await _data;
    data[key] = value;

    await _save(data);

    return;
  }

  @override
  Future<void> setBool(String key, bool value) {
    _cache[key] = value;
    return _set(key, value);
  }

  @override
  Future<void> setInt(String key, int value) {
    _cache[key] = value;
    return _set(key, value);
  }

  @override
  Future<void> setDouble(String key, double value) {
    _cache[key] = value;
    return _set(key, value);
  }

  @override
  Future<void> setString(String key, String value) {
    _cache[key] = value;
    return _set(key, value);
  }

  @override
  Future<void> setStringList(String key, List<String> value) {
    _cache[key] = value;
    return _set(key, value);
  }

  @override
  Future<void> remove(String key) async {
    _cache.remove(key);

    final data = await _data;
    data.remove(key);

    await _save(data);

    return;
  }

  /// Clears cache and platform preferences that match filter options.
  @override
  Future<void> clear() async {
    _cache.clear();
    await _save({});
    return;
  }
}
