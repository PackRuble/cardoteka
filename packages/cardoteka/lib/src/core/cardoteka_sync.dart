import 'dart:async';

import 'package:meta/meta.dart';

import '../card.dart';
import 'cardoteka_core.dart';
import 'storage/cardoteka_storage_sync.dart';

/// A synchronous implementation of a Cardoteka representing a wrapper over [SharedPreferencesWithCache].
///
/// {@macro cardoteka.CardotekaCore}
///
/// For synchronous [Cardoteka] you also need to do initialization
/// (once, though idempotent) via [Cardoteka.init].
///
/// A complete example of working with the asynchronous version of [Cardoteka]:
/// ```dart
/// main() async {
///   await Cardoteka.init();
///
///   final cardoteka = Cardoteka(
///     config: CardotekaConfig(
///       name: 'settings',
///       cards: SettingsCards.values,
///       converters: SettingsCards.converters,
///     ),
///   );
///
///   ThemeMode themeMode = cardoteka.get(SettingsCards.themeMode); // will return default value
///   await cardoteka.set<ThemeMode>(SettingsCards.themeMode, ThemeMode.light);
///   themeMode = cardoteka.get(SettingsCards.themeMode); // ThemeMode.light
///
///   DateTime? lastLoginTime = cardoteka.getOrNull(SettingsCards.lastLoginTime); // null
///   await cardoteka.setOrNull<DateTime>(SettingsCards.lastLoginTime, DateTime.now());
///   lastLoginTime = cardoteka.getOrNull(SettingsCards.lastLoginTime); // will return the saved time
///
///   cardoteka.getStoredCards(); // {SettingsCards.themeMode, SettingsCards.lastLoginTime}
///
///   await cardoteka.remove(SettingsCards.userColor); // nothing will happen
///   await cardoteka.remove(SettingsCards.lastLoginTime); // lastLoginTime removed from storage
///   cardoteka.getStoredEntries(); // {SettingsCards.themeMode: ThemeMode.light}
///
///   await cardoteka.removeAll();
///   cardoteka.getStoredCards(); // {}
/// }
/// ```
base class Cardoteka extends CardotekaCore {
  /// {@macro cardoteka.CardotekaCore.constructor}
  /// and create an instance of the [Cardoteka].
  Cardoteka({
    required super.config,
    required CardotekaStorage storage,
  }) : _storage = storage;

  /// A reference to an instance of [SharedPreferencesWithCache] from the package
  /// [shared_preferences](https://pub.dev/packages/shared_preferences)
  ///
  /// Initialization of this variable occurs after calling [init] and
  /// waiting for it.
  ///
  /// If you need to access this instance, use
  /// the 'package:cardoteka/access_to_sp.dart' import.
  /// This can also be useful in cases of gradual migration or quick testing
  /// of some hypotheses.
  final CardotekaStorage _storage;

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
  /// await Cardoteka.init();
  ///
  /// // ...and then create instances and use all the features
  /// final сardoteka = MyCardoteka(...);
  /// final result = сardoteka.get(...);
  /// ```
  // The result explicitly indicates that the given method can be executed in
  // a synchronous manner. However, this is in no way under the control of the user.
  // ignore: avoid_futureor_void
  FutureOr<void> init() async {
    if (!_isInitialized) {
      await _storage.create();
      _isInitialized = true;
    }
  }

  /// {@macro cardoteka.CardotekaCore.get}
  ///
  /// Works similarly to the [SharedPreferencesWithCache.get] method and
  /// others of the same name.
  @override
  V get<V extends Object>(Card<V> card) {
    _assertCheckInit();

    return getValueFromStorage(card) ?? card.defaultValue;
  }

  @override
  V? getOrNull<V extends Object?>(Card<V?> card) {
    _assertCheckInit();

    return getValueFromStorage(card);
  }

  @internal
  @protected
  @override
  V? getValueFromStorage<V>(Card<V?> card) {
    final key = getStorageKey(card);
    final Object? object = getObjectFromStorage(key, card.type);

    if (object == null) {
      // value was not in storage
      return object as V?;
    } else {
      return (getConverter(card)?.from(object) ?? object) as V?;
    }
  }

  @internal
  @protected
  @override
  Object? getObjectFromStorage(String key, DataType type) => switch (type) {
        // use internal implementation of `Object` to cast `List<String>`
        DataType.stringList => _storage.getStringList(key),
        _ => _storage.get(key),
      };

  /// {@macro cardoteka.CardotekaCore.set}
  ///
  /// Works similarly to the [SharedPreferencesWithCache.setBool] method and
  /// others of the same name.
  @override
  Future<bool> set<V extends Object>(Card<V?> card, V value) {
    _assertCheckInit();

    return super.set<V>(card, value);
  }

  @override
  Future<bool> setOrNull<V extends Object>(Card<V?> card, V? value) {
    _assertCheckInit();

    return super.setOrNull<V>(card, value);
  }

  @internal
  @protected
  @override
  Future<bool> setValueToStorage<V extends Object>(
    Card<V?> card,
    V value,
  ) async {
    final resultValue = getConverter(card)?.to(value) ?? value;
    final key = getStorageKey(card);
    await switch (card.type) {
      DataType.bool => _storage.setBool(key, resultValue as bool),
      DataType.int => _storage.setInt(key, resultValue as int),
      DataType.double => _storage.setDouble(key, resultValue as double),
      DataType.string => _storage.setString(key, resultValue as String),
      DataType.stringList =>
        _storage.setStringList(key, (resultValue as List).cast<String>()),
      // todo(20.02.2026, @PackRuble):
      DataType.object => throw UnimplementedError(),
    };
    // fixdep(16.01.2025): [The methods for removing and setting values return bool, but this is a fiction (always return `true`) · Issue #32 · PackRuble/cardoteka](https://github.com/PackRuble/cardoteka/issues/32)
    return true;
  }

  @override
  @protected
  Future<bool?> setObjectToStorage<V extends Object>(
    String key,
    V value,
  ) async {
    Object? result = Object();

    final void _ = await switch (value) {
      final bool value => _storage.setBool(key, value),
      final int value => _storage.setInt(key, value),
      final double value => _storage.setDouble(key, value),
      final String value => _storage.setString(key, value),
      final List value => value.isNotEmpty
          ? value.first is String
              ? _storage.setStringList(key, value.cast<String>())
              : result = null
          : _storage.setStringList(key, []),
      _ => result = null,
    };

    // fixdep(16.01.2025): [The methods for removing and setting values return bool, but this is a fiction (always return `true`) · Issue #32 · PackRuble/cardoteka](https://github.com/PackRuble/cardoteka/issues/32)
    return result == null ? null : true;
  }

  /// {@macro cardoteka.CardotekaCore.remove}
  ///
  /// Works similarly to the [SharedPreferencesWithCache.remove] method of the same name.
  @override
  Future<bool> remove(Card card) async {
    _assertCheckInit();

    watcher?.notify(card, null);
    await _storage.remove(getStorageKey(card));
    // fixdep(16.01.2025): [The methods for removing and setting values return bool, but this is a fiction (always return `true`) · Issue #32 · PackRuble/cardoteka](https://github.com/PackRuble/cardoteka/issues/32)
    return true;
  }

  @override
  Future<bool> removeAll() {
    _assertCheckInit();

    // We don't use the `_prefs.clear()` method because `prefs`
    // and `SharedPreferencesWithCache._cache` are common to all `Cardoteka` instances.
    // This could probably change in the future if `_prefs.clear` has
    // an explicit `allowList` option.
    //
    // The `super.removeAll` currently uses cyclic `remove`.
    return super.removeAll();
  }

  /// {@macro cardoteka.CardotekaCore.containsCard}
  ///
  /// Works similarly to the [SharedPreferencesWithCache.containsKey] method of the same name.
  @override
  bool containsCard(Card card) {
    _assertCheckInit();

    return _storage.containsKey(getStorageKey(card));
  }

  /// {@macro cardoteka.CardotekaCore.getStoredCards}
  ///
  /// Works similarly to the [SharedPreferencesWithCache.keys] of the same name.
  @override
  Set<Card> getStoredCards() {
    _assertCheckInit();

    final resultKeys = <Card>{
      for (final card in cards)
        if (_storage.keys.contains(getStorageKey(card))) card
    };

    return resultKeys;
  }

  @override
  Map<Card, Object> getStoredEntries() {
    _assertCheckInit();

    return {
      for (final Card card in getStoredCards()) card: getValueFromStorage(card)!
    };
  }

  /// The original [SharedPreferencesWithCache.reloadCache] method.
  ///
  /// This method will also notify all [watcher] listeners.
  Future<void> reloadCache() async {
    _assertCheckInit();

    await _storage.reloadCache();
    await watcher?.notifyAll();
  }

  /// Assert controlling the initialization state of the [Cardoteka]
  void _assertCheckInit() {
    assert(
      isInitialized,
      'The storage [${config.prefix}] was not initialized! '
      'Need to call `await Cardoteka.init()`.',
    );
  }
}

/// Contains various utilities, mainly designed for testing.
@visibleForTesting
base mixin CardotekaTestUtils on Cardoteka {
  /// A way to reset the initialization state.
  @visibleForTesting
  @internal
  void deInit() => Cardoteka._isInitialized = false;

  /// A way to access [_assertCheckInit] for testing.
  @internal
  @visibleForTesting
  void Function() get assertCheckInit => _assertCheckInit;
}
