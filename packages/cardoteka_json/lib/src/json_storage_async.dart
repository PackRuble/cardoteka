import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cardoteka/cardoteka.dart' show CardotekaStorage, DataType;

// todo(02.03.2026, @PackRuble): add cache
// todo(02.03.2026, @PackRuble): doc

class JsonStorageAsync implements CardotekaStorage {
  JsonStorageAsync(this.path, {this.indent = '  '}) {
    // todo(02.03.2026, @PackRuble): check and create a file, but XFile only has
    //  asynchronous operations
  }

  /// The [path] where the data file will be stored. If the file does not exist,
  /// it will be created synchronously recursively along the given path.
  final String path;

  /// The encoding of elements of lists and maps are indented and put on separate
  /// lines. The [indent] string is prepended to these elements, once for each
  /// level of indentation.
  ///
  /// If [indent] is `null`, the output is encoded as a single line.
  final String? indent;

  // use XFile
  // task(30.03.2026, @PackRuble): [Add support for UTF-16 · Issue #266 · dart-lang/core](https://github.com/dart-lang/core/issues/266)
  // task(30.03.2026, @PackRuble): [[cross_file] `readAsString` assumes bytes are UTF-16 · Issue #165120 · flutter/flutter](https://github.com/flutter/flutter/issues/165120)
  File get _file => File(path);

  Future<Object?> _getValue(String key) async {
    final data = await _getData(onlyKeys: {key});
    final result = data[key];
    return result;
  }

  Future<Map<String, dynamic>> _getData({
    Set<String>? onlyKeys,
    Set<String>? exceptKeys,
  }) async {
    Map<String, dynamic> result = {};

    final raw = await _file.readAsString();
    if (raw.isEmpty) return {};

    final data = jsonDecode(raw) as Map<String, dynamic>;

    if (onlyKeys == null) {
      if (exceptKeys == null) {
        result = data;
      } else {
        for (final entry in data.entries) {
          if (exceptKeys.contains(entry.key)) continue;
          if (!data.containsKey(entry.key)) continue;

          result[entry.key] = data[entry.key];
        }
      }
    } else {
      final keys = onlyKeys.difference(exceptKeys ?? {});

      for (final key in keys) {
        if (!data.containsKey(key)) continue;

        result[key] = data[key];
      }
    }

    return result;
  }

  Future<void> _saveData(Object? data) async {
    final jsonEncoder = JsonEncoder.withIndent(indent);
    final result = jsonEncoder.convert(data);
    await _file.writeAsString(result);
  }

  @override
  FutureOr<Set<String>> getKeys({
    Set<String>? onlyKeys,
    Set<String>? exceptKeys,
  }) async {
    final all = await getAll(onlyKeys: onlyKeys, exceptKeys: exceptKeys);

    return all.keys.toSet();
  }

  @override
  FutureOr<Map<String, dynamic>> getAll({
    Set<String>? onlyKeys,
    Set<String>? exceptKeys,
  }) async {
    final data = await _getData(onlyKeys: onlyKeys, exceptKeys: exceptKeys);
    return data;
  }

  @override
  FutureOr<T?> get<T extends Object>(String key, DataType type) async {
    final data = await _getValue(key);

    return data as T?;
  }

  @override
  Future<void> set<T extends Object>(String key, T? value, _) async {
    final data = await _getData();
    data[key] = value;

    await _saveData(data);
  }

  @override
  Future<bool> containsKey(String key) async {
    final keys = await getKeys(onlyKeys: {key});

    return keys.isNotEmpty;
  }

  @override
  Future<void> remove(String key) async {
    final data = await _getData();
    data.remove(key);

    await _saveData(data);
  }

  @override
  Future<void> clear({Set<String>? onlyKeys}) async {
    Map<String, dynamic> result;
    if (onlyKeys == null) {
      result = {};
    } else {
      result = await _getData();
      for (final key in onlyKeys) {
        result.remove(key);
      }
    }

    await _saveData(result);
  }

  @override
  Future<void> reloadCache() async {}
}
