import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card.dart';
import 'config.dart';
import 'converter.dart';
import 'utils/core_check.dart' show checkConfiguration;
import 'watcher.dart';

/// A wrapper over [SharedPreferences] and the core of the whole system [Cardoteka].
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
///     config: CardConfig(
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
/// - [AccessToSP] to access static fields [SharedPreferences] as well
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
abstract class Cardoteka {
  /// Use this constructor to pass a configuration [CardConfig] and create
  /// an instance of the [Cardoteka].
  Cardoteka({
    required CardConfig config,
  })  :
        // this behavior is not yet available for const classes
        // https://github.com/dart-lang/language/issues/2581
        //
        assert(checkConfiguration(config)),
        _config = config;

  /// List of [Card]'s for accessing the storage [SharedPreferences].
  UnmodifiableListView<Card> get cards => UnmodifiableListView(_config.cards);

  /// Configuration file containing important information about the [Card]s.
  /// - [CardConfig.name] is used to prefix the key in [SharedPreferences] for
  /// each of the [Cardoteka] instances;
  /// - [CardConfig.cards] list of all card keys for accessing the storage.
  /// Access via [cards] if necessary.
  /// - [CardConfig.converters] are used to convert a complex object to the base
  /// types defined in the [DataType] enumeration.
  final CardConfig _config;

  /// A reference to an instance of [SharedPreferences] from the package
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
  static late SharedPreferences _prefs;

  /// Specify if listeners should be notified of new values in the persistence storage.
  ///
  /// Use a mixin based on the [Watcher] interface.
  @internal
  Watcher? get watcher => null;

  /// Indicates whether the storage is initialized. Use the [init] method to
  /// initialize and wait for it to complete.
  ///
  /// If it returns true, you can start making and work with cardoteka instances.
  bool get isInitialized => _isInitialized;

  static bool _isInitialized = false;

  /// Initialization [Cardoteka]. It is necessary to wait for completion.
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
  static Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  /// Get a [CardConfig.name]-based key from the [_config] and [Card.key] to use
  /// in the [SharedPreferences] storage.
  String _keyForSP(Card card) => '${_config.name}.${card.key}';

  /// Get value from [SharedPreferences] storage using [Card]<[Object]>.
  ///
  /// The default behavior assumes that if [SharedPreferences] does not have
  /// a record with the provided card, then `defaultValue` will be returned.
  ///
  /// The returned object is always non-nullable.
  ///
  /// If you need to return a null-value when there is no record in storage
  ///   OR
  /// your card is of nullable type [Card]<[Object?]>,
  ///   then use the [getOrNull] method.
  V get<V extends Object>(Card<V> card) {
    _assertCheckInit();

    return _getValueFromSP<V>(card) ?? card.defaultValue;
  }

  /// Get value from [SharedPreferences] storage using [Card]<[Object?]>.
  ///
  /// If the record was not in the storage, then null will be returned. If you
  /// need to return a default value [Card.defaultValue] when there is no record
  /// in storage, use the [get] method.
  V? getOrNull<V extends Object?>(Card<V?> card) {
    _assertCheckInit();

    return _getValueFromSP<V>(card);
  }

  /// Internal method to retrieve data from [SharedPreferences].
  V? _getValueFromSP<V>(Card<V?> card) {
    final key = _keyForSP(card);

    final Object? value;
    if (card.type == DataType.stringList) {
      value = _prefs.getStringList(key);
    } else {
      // simple types do not need "as" now
      value = _prefs.get(key);
    }

    if (value == null) {
      // value was not in the storage
      return value as V?;
    } else {
      return (_getConverter(card)?.from(value) ?? value) as V?;
    }
  }

  /// Save the new value in [SharedPreferences] using [Card].
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
    _assertCheckInit();

    watcher?.notify<V?>(card, value);

    return _setValueToSP<V>(card, value);
  }

  /// Store the new value in [SharedPreferences] using [Card], which can be
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
    _assertCheckInit();

    bool toNotify = true;

    if (value == null) {
      toNotify = false;
      return remove(card);
    }

    if (toNotify) watcher?.notify<V?>(card, value);

    return _setValueToSP<V>(card, value);
  }

  /// Internal method to save data in [SharedPreferences].
  ///
  /// Returns true if the value was successfully saved.
  Future<bool> _setValueToSP<V extends Object>(Card<V?> card, V value) async {
    final resultValue = _getConverter(card)?.to(value) ?? value;
    final key = _keyForSP(card);
    switch (card.type) {
      case DataType.bool:
        return _prefs.setBool(key, resultValue as bool);
      case DataType.int:
        return _prefs.setInt(key, resultValue as int);
      case DataType.double:
        return _prefs.setDouble(key, resultValue as double);
      case DataType.string:
        return _prefs.setString(key, resultValue as String);
      case DataType.stringList:
        return _prefs.setStringList(key, (resultValue as List).cast<String>());
    }
  }

  /// Get the converter for the [Card] card. Returns null if there is no converter.
  Converter? _getConverter(Card card) => _config.converters?[card];

  /// Removes an entry by using [card] from persistent storage.
  /// The [watcher] will be notified anyway (if it is not null).
  ///
  /// If successful, it will return true.
  ///
  /// Works similarly to the [SharedPreferences.remove] method of the same name.
  Future<bool> remove(Card card) async {
    _assertCheckInit();

    watcher?.notify(card, null);
    return _prefs.remove(_keyForSP(card));
  }

  /// Iteratively removes all values associated with the provided [cards]
  /// from persistent storage.
  ///
  /// The [watcher] will be notified anyway (if it is not null).
  ///
  /// Returns true only if the result was true for each card.
  ///
  /// Works similarly to the [SharedPreferences.clear] method of the same name.
  Future<bool> removeAll() async {
    _assertCheckInit();

    bool overallResult = true;
    for (final card in cards) {
      overallResult &= await remove(card);
    }

    return overallResult;
  }

  /// Returns all [cards] that contains in the persistent storage.
  ///
  /// Works similarly to the [SharedPreferences.getKeys] method of the same name.
  Set<Card> getCards() {
    _assertCheckInit();

    final Set<String> allStoredKey = _prefs.getKeys();
    final resultKeys = <Card>{
      for (final card in cards)
        if (allStoredKey.contains(_keyForSP(card))) card
    };

    return resultKeys;
  }

  /// Returns true if persistent storage the contains the given [card].
  ///
  /// Works similarly to the [SharedPreferences.containsKey] method of the same name.
  Future<bool> containsCard(Card card) async {
    _assertCheckInit();

    return _prefs.containsKey(_keyForSP(card));
  }

  /// Returns all stored entities from the persistent storage.
  ///
  /// Works similarly to the [AccessToSP.getEntries] method of the same name.
  Map<Card, Object> getStoredEntries() =>
      {for (final Card card in getCards()) card: _getValueFromSP(card)!};

  /// The original [SharedPreferences.reload] method.
  Future<void> reload() async {
    await _prefs.reload();
    watcher?.notifyAll();
  }

  void _assertCheckInit() {
    assert(
      isInitialized,
      'The storage [${_config.name}] was not initialized! '
      'Need to call `await $runtimeType.init()`',
    );
  }
}

/// Get access to all the original methods of the [SharedPreferences] library.
///
/// Sometimes can be useful for debugging/testing or for use outside the system [Cardoteka].
mixin AccessToSP on Cardoteka {
  SharedPreferences get prefs => Cardoteka._prefs;

  /// The original [SharedPreferences.setPrefix] method.
  void setPrefix(
    String prefix,
    // todo: add [allowList] after upgrading SP
    /*{Set<String>? allowList}*/
  ) =>
      SharedPreferences.setPrefix(
        prefix, /*allowList: allowList*/
      );

  /// Returns all entries (key: value) in the persistent storage.
  Map<String, Object> getEntries() =>
      {for (final key in prefs.getKeys()) key: prefs.get(key)!};
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
  void Function() get resetStatic => SharedPreferences.resetStatic;

  /// The original [SharedPreferences.getInstance] method.
  ///
  /// Useful in tests after call [SharedPreferences.setMockInitialValues].
  @visibleForTesting
  Future<void> reInit() async =>
      Cardoteka._prefs = await SharedPreferences.getInstance();

  /// Acts according to the [SharedPreferences.setMockInitialValues] method of the same name.
  @visibleForTesting
  void setMockInitialValues(Map<Card<Object?>, Object> values) {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({
      for (final MapEntry<Card<Object?>, Object> entry in values.entries)
        _keyForSP(entry.key): _convertedValueForSP(entry.key, entry.value)
    });
  }

  V _convertedValueForSP<V extends Object>(Card<V?> card, Object value) {
    final Object result = _getConverter(card)?.to(value) ?? value;

    switch (card.type) {
      case DataType.bool:
        return (result as bool) as V;
      case DataType.int:
        return (result as int) as V;
      case DataType.double:
        return (result as double) as V;
      case DataType.string:
        return (result as String) as V;
      case DataType.stringList:
        return ((result as List).cast<String>()) as V;
    }
  }
}
