import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card.dart';
import 'config.dart';
import 'converter.dart';
import 'utils/core_check.dart' show checkConfiguration;
import 'watcher.dart';

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
class Cardoteka extends CardotekaAsync {
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

    return _getValueFromSP(card) ?? card.defaultValue;
  }

  @override
  V? getOrNull<V extends Object?>(Card<V?> card) {
    _assertCheckInit();

    return _getValueFromSP(card);
  }

  /// Internal method to retrieve data from [SharedPreferencesWithCache].
  @override
  V? _getValueFromSP<V>(Card<V?> card) {
    // todo(22.12.2024): можно выделить некоторые части в отдельный метод для переопределения
    final key = _keyForSP(card);

    final Object? value = switch (card.type) {
      // use internal implementation of `Object` to cast `List<String>`
      DataType.stringList => _prefs.getStringList(key),
      _ => _prefs.get(key),
    };

    if (value == null) {
      // value was not in cached storage
      return value as V?;
    } else {
      return (_getConverter(card)?.from(value) ?? value) as V?;
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
  Future<bool> _setValueToSP<V extends Object>(Card<V?> card, V value) async {
    final resultValue = _getConverter(card)?.to(value) ?? value;
    final key = _keyForSP(card);
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

    return _prefs.containsKey(_keyForSP(card));
  }

  /// Returns all [cards] that contains in the persistent storage.
  ///
  /// Works similarly to the [SharedPreferencesWithCache.keys] method of the same name.
  @override
  Set<Card> getStoredCards() {
    _assertCheckInit();

    final resultKeys = <Card>{
      for (final card in cards)
        if (_prefs.keys.contains(_keyForSP(card))) card
    };

    return resultKeys;
  }

  @override
  Map<Card, Object> getStoredEntries() {
    _assertCheckInit();

    return {
      for (final Card card in getStoredCards()) card: _getValueFromSP(card)!
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

    watcher?.notify(card, null);
    await _prefs.remove(_keyForSP(card));
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
      'The storage [${_config.name}] was not initialized! '
      'Need to call `await Cardoteka.init()`.',
    );
  }
}

class CardotekaAsync {
  /// Use this constructor to pass a configuration [CardotekaConfig] and create
  /// an instance of the [CardotekaAsync].
  CardotekaAsync({
    required CardotekaConfig config,
  })  :
        // fixdep(22.05.2023): this behavior is not yet available for const classes
        // https://github.com/dart-lang/language/issues/2581
        assert(checkConfiguration(config)),
        _config = config;

  /// List of [Card]'s for accessing the storage [SharedPreferencesAsync].
  UnmodifiableListView<Card> get cards => UnmodifiableListView(_config.cards);

  /// Configuration file containing important information about the [Card]s.
  /// - [CardotekaConfig.name] is used to prefix the key in [SharedPreferencesAsync] for
  /// each of the [CardotekaAsync] instances;
  /// - [CardotekaConfig.cards] list of all card keys for accessing the storage.
  /// Access via [cards] if necessary.
  /// - [CardotekaConfig.converters] are used to convert a complex object to the base
  /// types defined in the [DataType] enumeration.
  final CardotekaConfig _config;

  static final _prefsAsync = SharedPreferencesAsync();

  /// Specify if listeners should be notified of new values in the persistence storage.
  ///
  /// Use a mixin based on the [Watcher] interface.
  @internal
  Watcher? get watcher => null;

  /// Get a [CardotekaConfig.name]-based key from the [_config] and [Card.key] to use
  /// in the [SharedPreferencesAsync] storage.
  String _keyForSP(Card card) => '${_config.name}.${card.key}';

  /// Get value from [SharedPreferencesAsync] storage using [Card]<[Object]>.
  ///
  /// The default behavior assumes that if [SharedPreferencesAsync] does not have
  /// a record with the provided card, then `defaultValue` will be returned.
  ///
  /// The returned object is always non-nullable.
  ///
  /// If you need to return a null-value when there is no record in storage
  ///   OR
  /// your card is of nullable type [Card]<[Object?]>,
  ///   then use the [getOrNull] method.
  FutureOr<V> get<V extends Object>(Card<V> card) => Future(
        () async {
          return await _getValueFromSP<V>(card) ?? card.defaultValue;
        },
      );

  /// Get value from [SharedPreferencesAsync] storage using [Card]<[Object?]>.
  ///
  /// If the record was not in the storage, then null will be returned. If you
  /// need to return a default value [Card.defaultValue] when there is no record
  /// in storage, use the [get] method.
  FutureOr<V?> getOrNull<V extends Object?>(Card<V?> card) =>
      _getValueFromSP<V>(card);

  /// Internal method to retrieve data from [SharedPreferencesAsync].
  FutureOr<V?> _getValueFromSP<V>(Card<V?> card) async {
    final key = _keyForSP(card);

    final Object? value = await switch (card.type) {
      DataType.string => _prefsAsync.getString(key),
      DataType.int => _prefsAsync.getInt(key),
      DataType.double => _prefsAsync.getDouble(key),
      DataType.bool => _prefsAsync.getBool(key),
      DataType.stringList => _prefsAsync.getStringList(key),
    };

    if (value == null) {
      // value was not in the storage
      return value as V?;
    } else {
      return (_getConverter(card)?.from(value) ?? value) as V?;
    }
  }

  /// Save the new value in [SharedPreferencesAsync] using [Card].
  ///
  /// NOTE: Always specify a generic type and do so according to the type
  /// of your [Card.defaultValue]. This will help prevent compilation errors
  /// because without specifying a generic type, a type will be output
  /// based on the [card] provided and the stored [value].
  ///
  /// What you need to know:
  /// - type of [card] and [value] must match.
  /// - [value] cannot be `null`. Use [setOrNull] when you want if you want
  /// to simulate storing null.
  /// - [watcher] will be notified anyway (if it is not null).
  ///
  /// If successful, it will return true.
  Future<bool> set<V extends Object>(Card<V?> card, V value) async {
    watcher?.notify<V?>(card, value);

    return _setValueToSP<V>(card, value);
  }

  /// Store the new value in [SharedPreferencesAsync] using [Card], which can be
  /// of nullable type for [Card.defaultValue]. This method allows you to simulate
  /// saving of nullable values by saving or deleting them from storage. It means:
  /// - if you set null for a given [card] then the value will be removed
  /// from storage
  /// - any other value will be saved as usual.
  ///
  /// NOTE: Always specify a generic type and do so according to the type
  /// of your [Card.defaultValue]. This will help prevent compilation errors
  /// because without specifying a generic type, a type will be output
  /// based on the [card] provided and the stored [value].
  ///
  /// What you need to know:
  /// - type of [card] and [value] must match OR [value]=null.
  /// - use the regular [set] method if you won't be working with nullable values.
  /// - [watcher] will be notified anyway (if it is not null).
  ///
  /// If successful, it will return true:
  /// - if [value]==null, then the value was successfully removed
  /// - in any other case, the value was successfully saved
  Future<bool> setOrNull<V extends Object>(Card<V?> card, V? value) async {
    if (value == null) {
      await remove(card);
      // todo(22.12.2024): имитация успеха
      return true;
    } else {
      watcher?.notify<V?>(card, value);
      return _setValueToSP<V>(card, value);
    }
  }

  /// Internal method to save data in [SharedPreferencesAsync].
  ///
  /// Returns true if the value was successfully saved.
  Future<bool> _setValueToSP<V extends Object>(Card<V?> card, V value) async {
    final resultValue = _getConverter(card)?.to(value) ?? value;
    final key = _keyForSP(card);
    await switch (card.type) {
      DataType.bool => _prefsAsync.setBool(key, resultValue as bool),
      DataType.int => _prefsAsync.setInt(key, resultValue as int),
      DataType.double => _prefsAsync.setDouble(key, resultValue as double),
      DataType.string => _prefsAsync.setString(key, resultValue as String),
      DataType.stringList =>
        _prefsAsync.setStringList(key, (resultValue as List).cast<String>())
    };
    // todo(22.12.2024): имитация успеха
    return true;
  }

  /// Get the converter for the [Card] card. Returns null if there is no converter.
  Converter? _getConverter(Card card) => _config.converters?[card];

  /// Removes an entry by using [card] from persistent storage.
  /// The [watcher] will be notified anyway (if it is not null).
  ///
  /// If successful, it will return true.
  ///
  /// Works similarly to the [SharedPreferencesAsync.remove] method of the same name.
  Future<bool> remove(Card card) async {
    watcher?.notify(card, null);
    await _prefsAsync.remove(_keyForSP(card));
    // todo(22.12.2024): имитация успеха
    return true;
  }

  /// Iteratively removes all values associated with the provided [cards]
  /// from persistent storage.
  ///
  /// The [watcher] will be notified anyway (if it is not null).
  ///
  /// Returns true only if the result was true for each card.
  ///
  /// Works similarly to the [SharedPreferencesAsync.clear] method of the same name.
  Future<bool> removeAll() async {
    final results = await Future.wait([for (final card in cards) remove(card)]);
    final overallResult = results.fold(true, (prev, el) => prev && el);
    return overallResult;
  }

  /// Returns all [cards] that contains in the persistent storage.
  ///
  /// Works similarly to the [SharedPreferencesAsync.getKeys] method of the same name.
  FutureOr<Set<Card>> getStoredCards() => Future(
        () async {
          final Set<String> storedKeys = await _prefsAsync.getKeys(
            // todo(22.12.2024):
            allowList: null,
          );
          final resultKeys = <Card>{
            for (final card in cards)
              if (storedKeys.contains(_keyForSP(card))) card
          };

          return resultKeys;
        },
      );

  /// Returns true if persistent storage the contains the given [card].
  ///
  /// Works similarly to the [SharedPreferencesAsync.containsKey] method of the same name.
  FutureOr<bool> containsCard(Card card) async =>
      _prefsAsync.containsKey(_keyForSP(card));

  /// Returns all stored entities from the persistent storage.
  ///
  /// Works similarly to the [AccessToSP.getEntries] method of the same name.
  FutureOr<Map<Card, Object>> getStoredEntries() {
    return Future(
      () async => {
        // todo(22.12.2024): use getAll method
        for (final Card card in await getStoredCards())
          card: (await _getValueFromSP(card))!
      },
    );
  }
}

/// Get access to all the original methods of the [SharedPreferencesWithCache] library.
///
/// Sometimes can be useful for debugging/testing or for use outside the system [Cardoteka].
mixin AccessToSP on Cardoteka {
  SharedPreferencesWithCache get prefs => Cardoteka._prefs;

  /// Returns all entries (key: value) in the persistent storage.
  Map<String, Object> getEntries() =>
      {for (final key in prefs.keys) key: prefs.get(key)!};
}

/// Contains various utilities, mainly designed for testing.
@visibleForTesting
mixin CardotekaUtilsForTest on Cardoteka {
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
    final Object result = _getConverter(card)?.to(value) ?? value;

    return switch (card.type) {
      DataType.bool => (result as bool) as V,
      DataType.int => (result as int) as V,
      DataType.double => (result as double) as V,
      DataType.string => (result as String) as V,
      DataType.stringList => ((result as List).cast<String>()) as V
    };
  }
}
