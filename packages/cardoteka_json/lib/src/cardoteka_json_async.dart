import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cardoteka/cardoteka.dart';

class CardotekaJsonAsync implements CardotekaStorageAsync {
  CardotekaJsonAsync(this.config) : _file = File(config.path!)..createSync();

  @override
  final StorageConfig config;

  final File _file;

  Future<Map<String, dynamic>> get _data async {
    final data = await _file.readAsString();
    if (data.isEmpty) return {};
    return jsonDecode(data) as Map<String, dynamic>;
  }

  Future<void> _save(Map<String, dynamic> data) async {
    const encoder = JsonEncoder.withIndent('  ');
    final prettyData = encoder.convert(data);
    await _file.writeAsString(prettyData);
  }

  @override
  Future<Set<String>> getKeys({Set<String>? allowList}) async {
    final data = await _data;

    return data.keys.toSet();
  }

  @override
  Future<Map<String, Object?>> getAll({Set<String>? allowList}) async {
    final data = await _data;

    return data;
  }

  @override
  Future<bool?> getBool(String key) async {
    final data = await _data;

    return data[key] as bool?;
  }

  @override
  Future<int?> getInt(String key) async {
    final data = await _data;

    return data[key] as int?;
  }

  @override
  Future<double?> getDouble(String key) async {
    final data = await _data;

    return data[key] as double?;
  }

  @override
  Future<String?> getString(String key) async {
    final data = await _data;

    return data[key] as String?;
  }

  @override
  Future<List<String>?> getStringList(String key) async {
    final data = await _data;

    return (data[key] as List?)?.cast<String>().toList();
  }

  @override
  Future<bool> containsKey(String key) async {
    return (await getKeys(allowList: <String>{key})).isNotEmpty;
  }

  Future<void> _set(String key, dynamic value) async {
    final data = await _data;
    data[key] = value;

    await _save(data);

    return;
  }

  @override
  Future<void> setBool(String key, bool value) => _set(key, value);

  @override
  Future<void> setInt(String key, int value) => _set(key, value);

  @override
  Future<void> setDouble(String key, double value) => _set(key, value);

  @override
  Future<void> setString(String key, String value) => _set(key, value);

  @override
  Future<void> setStringList(String key, List<String> value) =>
      _set(key, value);

  @override
  Future<void> remove(String key) async {
    final data = await _data;
    data.remove(key);

    await _save(data);

    return;
  }

  @override
  Future<void> clear({Set<String>? allowList}) async {
    await _save({});
  }
}
