import 'dart:async';

import 'package:cardoteka/cardoteka.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show
        SharedPreferencesOptions,
        SharedPreferencesWithCache,
        SharedPreferencesWithCacheOptions;

// todo(21.02.2026, @PackRuble): use prefix
// todo(22.02.2026, @PackRuble): fix doc

class SpStorage implements CardotekaStorage {
  const SpStorage({this.prefix = ''});

  /// The name of your [CardotekaCore] instance. The [prefix] must be unique and
  /// not used in other instances.
  ///
  /// Under the hood, the name is used as prefixes for all cards.
  final String prefix;

  /// Get a [CardotekaConfig.prefix]-based key from the [config] and [Card.key]
  /// to use in storage.
  @internal
  @protected
  String getStorageKey(Card card) => '$prefix'
      '${prefix.isEmpty ? '' : '.'}'
      '${card.key}';

  /// A reference to an instance of [SharedPreferencesWithCache] from the package
  /// [shared_preferences](https://pub.dev/packages/shared_preferences)
  ///
  /// Initialization of this variable occurs after calling [init] and
  /// waiting for it.
  ///
  /// If you need to access this instance, use
  /// the 'package:cardoteka_sp/access_to_sp.dart' import.
  /// This can also be useful in cases of gradual migration or quick testing
  /// of some hypotheses.
  static late SharedPreferencesWithCache _prefs;

  /// Indicates whether the storage is initialized. Use the [init] method to
  /// initialize and wait for it to complete.
  ///
  /// If it returns true, you can start making and work with cardoteka instances.
  bool get isInitialized => _isInitialized;

  static bool _isInitialized = false;

  /// Initialization [Cardoteka]. It is necessary to wait for completion.
  /// Regardless of the number of Cardoteka instances, initialization must be
  /// performed once, although the method is idempotent. A subsequent call
  /// to [init] will not cause any action and will not throw an error.
  ///
  /// ```dart
  /// final storage = await SpStorage(...).init();
  /// final result = storage.get(...);
  /// ```
  /// The result explicitly indicates that the given method can be executed in
  /// a synchronous manner. However, this is in no way under the control
  /// of the user.
  FutureOr<SpStorage> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferencesWithCache.create(
        sharedPreferencesOptions: const SharedPreferencesOptions(),
        cacheOptions: const SharedPreferencesWithCacheOptions(
          // we don't want to enumerate all the cards because then we need
          // to access them on a static basis
          allowList: null,
        ),
        // todo(22.02.2026, @PackRuble): may be use?
        cache: null,
      );
      _isInitialized = true;
    }

    return this;
  }

  /// Works similarly to the [SharedPreferencesWithCache.keys] method
  /// of the same name.
  @override
  Set<String> getKeys({
    Set<String>? onlyKeys,
    Set<String>? exceptKeys,
  }) {
    _assertCheckInit();

    final keys = onlyKeys?.difference(exceptKeys ?? {});

    Set<String> result;
    result = _prefs.keys;

    if (keys == null && exceptKeys != null) {
      result = result.difference(exceptKeys);
    }

    return result;
  }

  /// Works similarly to the [SharedPreferencesWithCache.getAll] method
  /// of the same name.
  @override
  Map<String, dynamic> getAll({
    Set<String>? onlyKeys,
    Set<String>? exceptKeys,
  }) {
    _assertCheckInit();

    final data = <String, dynamic>{};

    final keys = getKeys(onlyKeys: onlyKeys, exceptKeys: exceptKeys);
    for (final key in keys) {
      data[key] = _prefs.get(key);
    }

    return data;
  }

  /// Works similarly to the [SharedPreferencesWithCache].get* methods.
  @override
  V? get<V extends Object>(String key, DataType<V> type) {
    _assertCheckInit();

    final result = switch (type) {
      DataType.string => _prefs.getString(key),
      DataType.int => _prefs.getInt(key),
      DataType.double => _prefs.getDouble(key),
      DataType.bool => _prefs.getBool(key),
      DataType.stringList => _prefs.getStringList(key),
      DataType.object => throw ArgumentError(
          'The `SharedPreferencesWithCache` does not support storing Object values.',
        ),
    };
    return result as V?;
  }

  /// Works similarly to the [SharedPreferencesWithCache].set* methods.
  @override
  Future<void> set<V extends Object>(
    String key,
    V? value,
    DataType<V>? type,
  ) async {
    _assertCheckInit();

    if (value == null) {
      await remove(key);
    } else {
      await switch (type) {
        DataType.bool => _prefs.setBool(key, value as bool),
        DataType.int => _prefs.setInt(key, value as int),
        DataType.double => _prefs.setDouble(key, value as double),
        DataType.string => _prefs.setString(key, value as String),
        DataType.stringList =>
          _prefs.setStringList(key, (value as List).cast<String>()),
        DataType.object || null => throw ArgumentError(
            'The shared_preferences does not support storing Object values.',
          ),
      };
    }
  }

  /// Works similarly to the [SharedPreferencesWithCache.containsKey] method
  /// of the same name.
  @override
  bool containsKey(String key) {
    _assertCheckInit();

    return _prefs.containsKey(key);
  }

  @override
  Future<void> remove(String key) async {
    _assertCheckInit();

    return _prefs.remove(key);
  }

  /// Works similarly to the [SharedPreferencesWithCache.clear] method
  /// of the same name.
  @override
  Future<void> clear({Set<String>? onlyKeys}) async {
    _assertCheckInit();

    final keys = getKeys(onlyKeys: onlyKeys);

    // We don't use the `SharedPreferencesWithCache.clear` method because `prefs`
    // and `SharedPreferencesWithCache._cache` are common to all `Cardoteka` instances.
    // This could probably change in the future if method has
    // an explicit `allowList` param.
    for (final key in keys) {
      await remove(key);
    }
  }

  /// Works similarly to the [SharedPreferencesWithCache.reloadCache] method
  /// of the same name.
  @override
  Future<void> reloadCache() async {
    _assertCheckInit();

    // todo(21.02.2026, @PackRuble): it is logical that it should be a static function in our case
    await _prefs.reloadCache();
  }

  /// Assert controlling the initialization state of the [Cardoteka]
  void _assertCheckInit() {
    assert(
      isInitialized,
      'The storage `$runtimeType` was not initialized! '
      'Need to call `await $runtimeType.init()`.',
    );
  }
}

/// Contains various utilities, mainly designed for testing.
@visibleForTesting
base mixin SpStorageTestUtils on SpStorage {
  /// A way to reset the initialization state.
  @visibleForTesting
  void deInit() => SpStorage._isInitialized = false;

  /// A way to access [_assertCheckInit] for testing.
  @visibleForTesting
  void Function() get assertCheckInit => _assertCheckInit;
}
