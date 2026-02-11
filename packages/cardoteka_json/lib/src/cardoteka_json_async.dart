import 'dart:async';
import 'dart:convert';
import 'dart:typed_data' show Uint8List;

import 'package:cardoteka/cardoteka.dart';
import 'package:cross_file/cross_file.dart' show XFile;
import 'package:rfc_6901/rfc_6901.dart';

// todo(11.02.2026, @PackRuble): temporarily impl based on rfc_6901
class CardotekaJsonAsync implements CardotekaStorageAsync {
  CardotekaJsonAsync(this.path);

  // todo(11.02.2026, @PackRuble): need to create file?

  final String path;

  // todo(11.02.2026, @PackRuble): return Map
  dynamic _getDecodedData() async {
    final file = XFile(path);
    final source = await file.readAsString();
    final result = jsonDecode(source);
    return result;
  }

  Future<void> _saveData(Object? data) async {
    final result = jsonEncode(data);

    final file = XFile(
      path,
      bytes: Uint8List.fromList(result.codeUnits),
      // todo(09.02.2026, @PackRuble): specify all params
    );

    await file.saveTo(path);
  }

  @override
  Future<Set<String>> getKeys({
    Set<String>? allowKeys,
    Set<String>? ignoreKeys,
  }) async {
    final all = await getAll(allowKeys: allowKeys, ignoreKeys: ignoreKeys);

    return all.keys.toSet();
  }

  @override
  Future<Map<String, Object?>> getAll({
    Set<String>? allowKeys,
    Set<String>? ignoreKeys,
  }) async {
    // todo(09.02.2026, @PackRuble): common assert allowKeys|ignoreKeys
    // todo(09.02.2026, @PackRuble): use ignoreKeys

    final data = await _getDecodedData();
    return (data as Map).cast<String, Object?>();
  }

  @override
  Future<T?> get<T extends Object>(String key, DataType<T> type) async {
    final data = await _getDecodedData();

    final pointer = JsonPointer('/$key');
    final result = pointer.read(data, orElse: () => null);

    return result as T?;
  }

  @override
  Future<void> set<T extends Object>(
    String key,
    T? value,
    DataType<T> type,
  ) async {
    final data = await _getDecodedData();

    final pointer = JsonPointer('/$key');
    final result = pointer.write(data, value);

    await _saveData(result);
  }

  @override
  Future<bool> containsKey(String key) async {
    final data = await _getDecodedData();

    final pointer = JsonPointer('/$key');
    final value = pointer.read(data, orElse: () => null);
    return value != null;
  }

  @override
  Future<void> remove(String key) async {
    final data = await _getDecodedData();

    final pointer = JsonPointer('/$key');
    final result = pointer.remove(data);

    await _saveData(result);
  }

  @override
  Future<void> clear({
    Set<String>? allowKeys,
    Set<String>? ignoreKeys,
  }) async {
    // todo(09.02.2026, @PackRuble): common assert allowKeys|ignoreKeys

    final data = await _getDecodedData();

    Set<String> resultKeys;
    final allKeys = await getKeys();
    if (ignoreKeys != null) {
      resultKeys = allKeys.difference(ignoreKeys);
    } else {
      resultKeys = allKeys;
    }

    var result = data;
    for (final key in resultKeys) {
      final pointer = JsonPointer('/$key');
      result = pointer.remove(result);
    }

    await _saveData(result);
  }
}
