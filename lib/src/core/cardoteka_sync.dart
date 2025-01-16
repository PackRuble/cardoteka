import 'dart:async';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesWithCache, SharedPreferencesWithCacheOptions;

import '../card.dart';
import 'cardoteka_core.dart';

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
  Cardoteka({required super.config});

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
  /// await Cardoteka.init();
  ///
  /// // ...and then create instances and use all the features
  /// final сardoteka = MyCardoteka(...);
  /// final result = сardoteka.get(...);
  /// ```
  /// // todo(22.12.2024): doc migrateV2
  static FutureOr<void> init(
      // {required bool migrateV2}
      ) async {
    if (!_isInitialized) {
      // todo(22.12.2024): use migrateV2
      // _prefsOld = await SharedPreferences.getInstance();
      _prefs = await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(
          // we don't want to enumerate all the cards because then we need
          // to access them on a static basis
          // ignore: avoid_redundant_argument_values
          allowList: null,
        ),
      );
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
    final Object? object = switch (card.type) {
      // use internal implementation of `Object` to cast `List<String>`
      DataType.stringList => _prefs.getStringList(key),
      _ => _prefs.get(key),
    };

    if (object == null) {
      // value was not in storage
      return object as V?;
    } else {
      return (getConverter(card)?.from(object) ?? object) as V?;
    }
  }

  /// {@macro cardoteka.CardotekaCore.set}
  ///
  /// Works similarly to the [SharedPreferencesWithCache.setBool] method and
  /// others of the same name.
  @override
  Future<bool> set<V extends Object>(Card<V?> card, V value) async {
    _assertCheckInit();

    return super.set<V>(card, value);
  }

  @override
  Future<bool> setOrNull<V extends Object>(Card<V?> card, V? value) async {
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
      DataType.bool => _prefs.setBool(key, resultValue as bool),
      DataType.int => _prefs.setInt(key, resultValue as int),
      DataType.double => _prefs.setDouble(key, resultValue as double),
      DataType.string => _prefs.setString(key, resultValue as String),
      DataType.stringList =>
        _prefs.setStringList(key, (resultValue as List).cast<String>())
    };
    // fixdep(16.01.2025): [The methods for removing and setting values return bool, but this is a fiction (always return `true`) · Issue #32 · PackRuble/cardoteka](https://github.com/PackRuble/cardoteka/issues/32)
    return true;
  }

  /// {@macro cardoteka.CardotekaCore.remove}
  ///
  /// Works similarly to the [SharedPreferencesWithCache.remove] method of the same name.
  @override
  Future<bool> remove(Card card) async {
    _assertCheckInit();

    watcher?.notify(card, null);
    await _prefs.remove(getStorageKey(card));
    // fixdep(16.01.2025): [The methods for removing and setting values return bool, but this is a fiction (always return `true`) · Issue #32 · PackRuble/cardoteka](https://github.com/PackRuble/cardoteka/issues/32)
    return true;
  }

  @override
  Future<bool> removeAll() async {
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

    return _prefs.containsKey(getStorageKey(card));
  }

  /// {@macro cardoteka.CardotekaCore.getStoredCards}
  ///
  /// Works similarly to the [SharedPreferencesWithCache.keys] of the same name.
  @override
  Set<Card> getStoredCards() {
    _assertCheckInit();

    final resultKeys = <Card>{
      for (final card in cards)
        if (_prefs.keys.contains(getStorageKey(card))) card
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
  /// Attention, this method does not launch an update for [watcher]s.
  Future<void> reloadCache() {
    _assertCheckInit();

    return _prefs.reloadCache();
  }

  /// Assert controlling the initialization state of the [Cardoteka]
  void _assertCheckInit() {
    assert(
      isInitialized,
      'The storage [${config.name}] was not initialized! '
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
