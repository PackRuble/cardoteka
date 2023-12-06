import 'dart:async';
import 'dart:collection';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card.dart';
import 'config.dart';
import 'converter.dart';
import 'utils/core_check.dart' show checkConfiguration;
import 'watcher.dart';

/// A handy wrapper for typed use [SharedPreferences].
///
/// todo: example for use
abstract class Cardoteka {
  Cardoteka({
    required CardConfig config,
  })  :
        // this behavior is not yet available for const classes
        // https://github.com/dart-lang/language/issues/2581
        //
        assert(checkConfiguration(config)),
        _config = config;

  /// List of keys [Card] for accessing the storage [SharedPreferences].
  UnmodifiableListView<Card> get cards => UnmodifiableListView(_config.cards);

  /// Configuration file containing important information about the [Card]s.
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

  /// Indicates whether the database is initialized. Use the [init] method to
  /// initialize and wait for it to complete.
  ///
  /// If it returns true, you can start making queries.
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

  /// Get the key to use it in the [SharedPreferences].
  String _keyForSP(Card card) => '${_config.name}.${card.key}';

  /// Get value from [SharedPreferences] using key type [Card].
  ///
  /// The default behavior assumes that if [SharedPreferences] does not have
  /// a record with the provided key, then `defaultValue` will be returned.
  ///
  /// The returned object is always non-nullable.
  V get<V extends Object>(Card<V> card) {
    _assertCheckInit();

    return _getValueFromSP<V>(card) ?? card.defaultValue;
  }

  /// The return null will mean there is no value in the persistent storage.
  ///
  /// [Card.defaultValue] is not used in this case.
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

  /// Save the new value in [SharedPreferences] using a key of type [Card].
  /// NOTE: Always specify the generic type and do so according to [Card.type]
  ///
  /// The [value] cannot be `null`. Use [setOrNull] when you want to simulate null.
  ///
  /// All [watcher]s will be notified.
  Future<bool> set<V extends Object>(Card<V?> card, V value) async {
    _assertCheckInit();

    watcher?.notify<V>(card, value);

    return _setValueToSP<V>(card, value);
  }

  /// Save the new value in [SharedPreferences] using [card] if ([value] != null).
  /// Otherwise the value will be deleted from the database to simulate null.
  ///
  /// All [watcher]s will be notified anyway.
  Future<bool?> setOrNull<V extends Object>(Card<V?> card, V? value) async {
    _assertCheckInit();

    bool toNotify = true;

    if (value == null) {
      toNotify = false;
      await remove(card);
      return null;
    }

    if (toNotify) watcher?.notify<V>(card, value);

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

  /// Acts according to the [SharedPreferences.remove] method of the same name.
  /// Removes an entry by using [card] from persistent storage.
  ///
  /// If successful, it will return true.
  Future<bool> remove(Card card) async {
    _assertCheckInit();

    watcher?.notify(card, card.defaultValue);
    return _prefs.remove(_keyForSP(card));
  }

  /// Acts according to the [SharedPreferences.clear] method of the same name.
  ///
  /// Iteratively removes all values associated with the provided [cards]
  /// from persistent storage.
  ///
  /// Returns true only if the result was true for each card.
  Future<bool> removeAll() async {
    _assertCheckInit();

    bool overallResult = true;
    for (final card in cards) {
      overallResult &= await remove(card);
    }

    return overallResult;
  }

  /// Acts according to the [SharedPreferences.getKeys] method of the same name.
  ///
  /// Returns all [cards] that contains in the persistent storage.
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
  Future<bool> containsCard(Card card) async {
    _assertCheckInit();

    return _prefs.containsKey(_keyForSP(card));
  }

  /// Acts according to the [AccessToSP.getEntries] method of the same name.
  ///
  /// Returns all stored entities from the persistent storage.
  Map<Card, Object> getStoredEntries() {
    _assertCheckInit();

    return {for (final Card card in getCards()) card: _getValueFromSP(card)!};
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

  /// The original [SharedPreferences.resetStatic] method.
  @visibleForTesting
  // ignore: invalid_use_of_visible_for_testing_member
  void resetStatic() => SharedPreferences.resetStatic();

  /// The original [SharedPreferences.getInstance] method.
  ///
  /// Useful in tests after call [SharedPreferences.setMockInitialValues].
  @visibleForTesting
  Future<void> reInit() async =>
      Cardoteka._prefs = await SharedPreferences.getInstance();

  /// Returns all entries (key: value) in the persistent storage.
  Map<String, Object> getEntries() =>
      {for (final key in prefs.getKeys()) key: prefs.get(key)!};
}

/// Contains various utilities, mainly designed for testing.
@visibleForTesting
@internal
mixin CardotekaUtilsForTest on Cardoteka {
  /// A way to reset the initialization state.
  @visibleForTesting
  @internal
  void deInit() => Cardoteka._isInitialized = false;

  /// A way to access [_assertCheckInit] for testing.
  @internal
  @visibleForTesting
  void Function() get assertCheckInit => _assertCheckInit;

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

  /// Acts according to the [SharedPreferences.setMockInitialValues] method of the same name.
  @visibleForTesting
  void setMockInitialValues(Map<Card<Object?>, Object> values) {
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({
      for (final MapEntry<Card<Object?>, Object> entry in values.entries)
        _keyForSP(entry.key): _convertedValueForSP(entry.key, entry.value)
    });
  }
}
