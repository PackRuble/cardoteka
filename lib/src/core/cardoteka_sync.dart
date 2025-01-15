import 'dart:async';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferencesWithCache, SharedPreferencesWithCacheOptions;

import '../card.dart';
import 'cardoteka_core.dart';

/// A wrapper over [SharedPreferencesWithCache] and the core of the whole system [Cardoteka].
/// Allows the use of typed [Card]'s to access storage.
///
/// A typical use case looks like this:
/// ```dart
/// // one of the data types that we would like to store
/// enum UserPage { home, search, favorites, settings }
///
/// // after that define the cards -> key:type-defaultValue-[staticKey]
/// enum SettingsCards<T> implements Card<T> {
///   homePage<UserPage>(DataType.string, UserPage.search),
///   userColor<Color>(DataType.int, Color.fromARGB(255, 79, 199, 112)),
///   lastLoginTime<DateTime?>(DataType.int, null, 'last_login_time_key'),
///   themeDefault<String>(DataType.string, 'mustard'),
///   themeMode<ThemeMode>(DataType.int, ThemeMode.dark),
///   startPage<int>(DataType.int, 104),
///   sessionDuration<Duration>(DataType.int, Duration(days: 1)),
///   ;
///
///   const SettingsCards(this.type, this.defaultValue, [this.customKey]);
///
///   @override
///   final DataType type;
///
///   @override
///   final T defaultValue;
///
///   final String? customKey;
///
///   @override
///   String get key => customKey ?? name;
///
///   static Map<SettingsCards, Converter> get converters => const {
///         themeMode: EnumAsIntConverter(UserPage.values),
///         lastLoginTime: Converters.dateTimeAsInt,
///         homePage: EnumAsStringConverter(UserPage.values),
///         sessionDuration: Converters.durationAsInt,
///       };
/// }
///
/// // then we define the class of our cardoteka
/// class MyStorage extends Cardoteka {
///   MyStorage({required super.config});
/// }
///
/// // initialize and use
/// main() async {
///   await Cardoteka.init();
///
///   final cardoteka = SettingsCardoteka(
///     config: CardotekaConfig(
///       name: 'SettingsCardoteka',
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
///   cardoteka.getCards(); // {SettingsCards.themeMode, SettingsCards.lastLoginTime}
///
///   await cardoteka.remove(SettingsCards.userColor); // nothing will happen
///   await cardoteka.remove(SettingsCards.lastLoginTime); // lastLoginTime removed from storage
///   cardoteka.getStoredEntries(); // {SettingsCards.themeMode: ThemeMode.light}
///
///   await cardoteka.removeAll();
///   cardoteka.getCards(); // {}
/// }
/// ```
///
/// To make it easier to understand what is happening, there is a “usage plan”:
///
/// 1. Define all values in [Card], using [Enum] to do so.
///   - implement the [Card] interface and define all required fields
///   - for each card, identify
///     - name (will be used as key. It shouldn't change after),
///     - <generic> for type designation for default value
///     - type to which the value will be converted. Select the appropriate one
///     from the [DataType] enumeration,
///     - default value. It will be returned when using [Cardoteka.get],
///     if there were no saves in the storage for this card previously.
///   - converters if generic type does not match your [Card.type]
///
/// 2. Define a class extending from [Cardoteka]. Either pass the configuration
/// directly to the super class, or use required parameters.
/// At this stage you can also add the necessary [mixin]s to extend
/// the functionality of your cardoteka:
/// - [WatcherImpl] to implement listening for changes to values in your storage.
/// Use your implementation if necessary, extending from [Watcher].
/// - [AccessToSP] to access static fields [SharedPreferencesWithCache] as well
/// as the singleton itself [_prefs]. If you needed this, you probably already
/// know what you're doing.
/// - [CRUD] to use familiar basic CRUD operations (create, read, update, delete).
/// This is nothing more than an imitation based on the [Cardoteka.get],
/// [Cardoteka.set] and [Cardoteka.remove] methods.
/// - [CardotekaUtilsForTest] for use during tests.
///
/// 3. Perform initialization (once) via [Cardoteka.init] and take advantage of
/// all the features of your cardoteka! Save, read, delete, listen to your saved
/// data using typed cards.
///
/// Don't worry! If you do something wrong, you will receive a detailed
/// correction message in the console.
base class Cardoteka extends CardotekaCore {
  Cardoteka({required super.config});

  /// A reference to an instance of [SharedPreferencesWithCache] from the package
  /// [shared_preferences](https://pub.dev/packages/shared_preferences)
  ///
  /// Initialization of this variable occurs after calling [init] and
  /// waiting for it.
  ///
  /// If you need to access this instance, use the [AccessToSP] mixin.
  /// The purposes of this action may be different, for example, using dynamic
  /// keys:
  /// ```dart
  /// // use AccessToSP mixin
  /// class MyCardoteka extends Cardoteka with AccessToSP {...}
  ///
  /// // ...
  /// MyCardoteka cardoteka;
  /// // ... and after init
  /// cardoteka.prefs.setInt('dynamic_key', 123);
  /// cardoteka.prefs.getBool('isDark');
  /// ```
  ///
  /// This can also be useful in cases of gradual migration or quick testing
  /// of some hypotheses.
  static late SharedPreferencesWithCache _prefs;

  /// Indicates whether the storage is initialized. Use the [init] method to
  /// initialize and wait for it to complete.
  ///
  /// If it returns true, you can start making and work with cardoteka instances.
  bool get isInitialized => _isInitialized;

  static bool _isInitialized = false;

  /// Initialization [CardotekaAsync]. It is necessary to wait for completion.
  /// Regardless of the number of Cardoteka instances, initialization must be
  /// performed once.
  ///
  /// A subsequent call to [init] will not cause any action and will not throw
  /// an error.
  ///
  /// ```dart
  /// await Cardoteka.init();
  ///
  /// // ...and then create instances and use all the features
  /// final myCardoteka = MyCardoteka(...);
  /// final result = myCardoteka.get(...);
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

  @override
  V get<V extends Object>(Card<V> card) {
    _assertCheckInit();

    return getValueFromSP(card) ?? card.defaultValue;
  }

  @override
  V? getOrNull<V extends Object?>(Card<V?> card) {
    _assertCheckInit();

    return getValueFromSP(card);
  }

  /// Internal method to retrieve data from [SharedPreferencesWithCache].
  @override
  V? getValueFromSP<V>(Card<V?> card) {
    // todo(22.12.2024): можно выделить некоторые части в отдельный метод для переопределения
    final key = keyForSP(card);

    final Object? value = switch (card.type) {
      // use internal implementation of `Object` to cast `List<String>`
      DataType.stringList => _prefs.getStringList(key),
      _ => _prefs.get(key),
    };

    if (value == null) {
      // value was not in cached storage
      return value as V?;
    } else {
      return (getConverter(card)?.from(value) ?? value) as V?;
    }
  }

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

  @override
  Future<bool> setValueToSP<V extends Object>(Card<V?> card, V value) async {
    final resultValue = getConverter(card)?.to(value) ?? value;
    final key = keyForSP(card);
    await switch (card.type) {
      DataType.bool => _prefs.setBool(key, resultValue as bool),
      DataType.int => _prefs.setInt(key, resultValue as int),
      DataType.double => _prefs.setDouble(key, resultValue as double),
      DataType.string => _prefs.setString(key, resultValue as String),
      DataType.stringList =>
        _prefs.setStringList(key, (resultValue as List).cast<String>())
    };
    // todo(22.12.2024): имитация успеха
    return true;
  }

  /// Returns true if persistent storage the contains the given [card].
  ///
  /// Works similarly to the [SharedPreferencesWithCache.containsKey] method of the same name.
  @override
  bool containsCard(Card card) {
    _assertCheckInit();

    return _prefs.containsKey(keyForSP(card));
  }

  /// Returns all [cards] that contains in the persistent storage.
  ///
  /// Works similarly to the [SharedPreferencesWithCache.keys] method of the same name.
  @override
  Set<Card> getStoredCards() {
    _assertCheckInit();

    final resultKeys = <Card>{
      for (final card in cards)
        if (_prefs.keys.contains(keyForSP(card))) card
    };

    return resultKeys;
  }

  @override
  Map<Card, Object> getStoredEntries() {
    _assertCheckInit();

    return {
      for (final Card card in getStoredCards()) card: getValueFromSP(card)!
    };
  }

  /// Removes an entry by using [card] from persistent storage.
  /// The [watcher] will be notified anyway (if it is not null).
  ///
  /// If successful, it will return true.
  ///
  /// Works similarly to the [SharedPreferencesWithCache.remove] method of the same name.
  @override
  Future<bool> remove(Card card) async {
    _assertCheckInit();

    await super.remove(card);
    await _prefs.remove(keyForSP(card));
    // todo(22.12.2024): имитация успеха
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

  /// The original [SharedPreferencesWithCache.reload] method.
  ///
  /// Attention, this method does not launch an update for watchers.
  Future<void> reloadCache() {
    _assertCheckInit();

    return _prefs.reloadCache();
  }

  void _assertCheckInit() {
    assert(
      isInitialized,
      'The storage [${config.name}] was not initialized! '
      'Need to call `await Cardoteka.init()`.',
    );
  }
}

/// Get access to all the original methods of the [SharedPreferencesWithCache] library.
///
/// Sometimes can be useful for debugging/testing or for use outside the system [Cardoteka].
base mixin AccessToSP on Cardoteka {
  SharedPreferencesWithCache get prefs => Cardoteka._prefs;

  /// Returns all entries (key: value) in the persistent storage.
  Map<String, Object> getEntries() =>
      {for (final key in prefs.keys) key: prefs.get(key)!};
}

/// Contains various utilities, mainly designed for testing.
@visibleForTesting
base mixin CardotekaUtilsForTest on Cardoteka {
  /// A way to reset the initialization state.
  @visibleForTesting
  @internal
  void deInit() => Cardoteka._isInitialized = false;

  /// A way to access [_assertCheckInit] for testing.
  @internal
  @visibleForTesting
  void Function() get assertCheckInit => _assertCheckInit;

  /// The original [SharedPreferences.resetStatic] method.
  @visibleForTesting
  // ignore: invalid_use_of_visible_for_testing_member
  // todo(22.12.2024): удалить
  // void Function() get resetStatic => SharedPreferencesAsync.resetStatic;

  /// The original [SharedPreferences.getInstance] method.
  ///
  /// Useful in tests after call [SharedPreferences.setMockInitialValues].
  // todo(22.12.2024): изменить
  // @visibleForTesting
  // Future<void> reInit() async =>
  //     Cardoteka._prefs = await SharedPreferences.getInstance();

  /// Acts according to the [SharedPreferences.setMockInitialValues] method of the same name.
  @visibleForTesting
  // todo(22.12.2024): удалить
  void setMockInitialCards(Map<Card<Object?>, Object> values) {
    // ignore: invalid_use_of_visible_for_testing_member
    // SharedPreferences.setMockInitialValues({
    //   for (final MapEntry<Card<Object?>, Object> entry in values.entries)
    //     _keyForSP(entry.key): _convertedValueForSP(entry.key, entry.value)
    // });
  }

  /// The original [SharedPreferences.setMockInitialValues] method.
  @visibleForTesting
  // todo(22.12.2024): удалить
  static void setMockInitialValues(Map<String, Object> values) {
    // ignore: invalid_use_of_visible_for_testing_member
    // SharedPreferences.setMockInitialValues(values);
  }

  V _convertedValueForSP<V extends Object>(Card<V?> card, Object value) {
    final Object result = getConverter(card)?.to(value) ?? value;

    return switch (card.type) {
      DataType.bool => (result as bool) as V,
      DataType.int => (result as int) as V,
      DataType.double => (result as double) as V,
      DataType.string => (result as String) as V,
      DataType.stringList => ((result as List).cast<String>()) as V
    };
  }
}
