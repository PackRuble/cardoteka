import 'dart:async';

import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'card.dart';
import 'config.dart';
import 'converter.dart';
import 'utils/core_check.dart';
import 'watcher.dart';

/// A handy wrapper for typed use [SharedPreferences].
///
/// Todo: example for use
abstract class Cardoteka {
  Cardoteka({
    required Config config,
  })  :
        // this behavior is not yet available for const classes
        // https://github.com/dart-lang/language/issues/2581
        //
        assert(checkConfiguration(config)),
        _config = config;

  /// List of keys [Card] for accessing the database [SharedPreferences].
  List<Card> get cards => _config.cards;

  /// Configuration file.
  final Config _config;

  static late SharedPreferences _prefs;

  /// Specify if listeners should be notified of new values in the persistence storage.
  ///
  /// Use a mixin based on the [Watcher] interface.
  @internal
  Watcher? get watcher => null;
  // todo: наш нотифаер не уведомляется, если значение будет удалено

  /// Indicates whether the database is initialized. Use the [init] method to
  /// initialize and wait for it to complete.
  ///
  /// If it returns true, you can start making queries.
  bool get isInitialized => _isInitialized;

  static bool _isInitialized = false;

  /// Initialization [Cardoteka]. It is necessary to wait for completion.
  static Future<void> init() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
    }
  }

  // /// Get the key after [SharedPreferences].
  // String _getKeyFromDb(String key) => key.split(_separatorKey)[1];

  /// Get the key to use it in the [SharedPreferences].
  String _keyForSP(Card card) => '${_config.name}.${card.key}';

  /// Get value from [SharedPreferences] using key type [Card].
  ///
  /// The default behavior assumes that if [SharedPreferences] does not have
  /// a record with the provided key, then `defaultValue` will be returned.
  ///
  /// The returned object is always non-nullable.
  T get<T extends Object>(Card<T> card) {
    _checkInit();

    return _getValueFromDb<T>(card) ?? card.defaultValue;
  }

  /// The return null will mean there is no value in the persistent storage.
  ///
  /// [Card.defaultValue] is not used in this case.
  T? getOrNull<T extends Object?>(Card<T?> card) {
    _checkInit();

    return _getValueFromDb<T>(card);
  }

  /// Internal method to retrieve data from [SharedPreferences].
  T? _getValueFromDb<T>(Card<T?> card) {
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
      return value as T?;
    } else {
      return (_getConverter(card)?.from(value) ?? value) as T?;
    }
  }

  /// Save the new value in [SharedPreferences] using a key of type [Card].
  /// NOTE: Always specify the generic type and do so according to [Card.type]
  ///
  /// The [value] cannot be `null`. Use [setOrNull] when you want to simulate null.
  ///
  /// All [watcher]s will be notified.
  Future<bool> set<T extends Object>(Card<T?> card, T value) async {
    _checkInit();

    watcher?.notify<T>(card, value);

    return _setValueToDb<T>(card, value);
  }

  /// Save the new value in [SharedPreferences] using [card] if ([value] != null).
  /// Otherwise the value will be deleted from the database to simulate null.
  ///
  /// All [watcher]s will be notified anyway.
  Future<bool?> setOrNull<T extends Object>(Card<T?> card, T? value) async {
    _checkInit();

    watcher?.notify<T>(card, value);

    if (value == null /* && value is! T */) {
      await remove(card);
      return null;
    }

    return _setValueToDb<T>(card, value);
  }

  /// Internal method to save data in [SharedPreferences].
  ///
  /// Returns true if the value was successfully saved.
  Future<bool> _setValueToDb<T extends Object>(Card<T?> card, T value) async {
    final resultValue = _getConverter(card)?.to(value) ?? value;

    final key = _keyForSP(card);
    // optimize: use a pre-made map?
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
  Converter? _getConverter(Card card) {
    final Map<Card, Converter>? converters = _config.converters;
    if (converters != null) {
      if (converters.containsKey(card)) {
        return converters[card]!;
      }
    }
    return null;
  }

  /// Acts according to the [SharedPreferences.remove] method of the same name.
  /// Removes an entry by using [card] from persistent storage.
  ///
  /// If successful, it will return true.
  Future<bool> remove(Card card) async {
    _checkInit();

    return _prefs.remove(_keyForSP(card));
  }

  /// Acts according to the [SharedPreferences.clear] method of the same name.
  ///
  /// Iteratively removes all values associated with the provided [cards]
  /// from persistent storage.
  ///
  /// Returns true if the operation was successful.
  ///
  Future<bool> removeAll() async {
    for (final card in cards) {
      await remove(card);
    }

    return true;
  }

  /// Acts according to the [SharedPreferences.getKeys] method of the same name.
  ///
  /// Returns all [cards] that contains in the persistent storage.
  Set<Card> getCards() {
    _checkInit();

    final Set<String> allStoredKey = _prefs.getKeys();
    final resultKeys = <Card>{
      for (final card in cards)
        if (allStoredKey.contains(_keyForSP(card))) card
    };

    return resultKeys;
  }

  /// Returns true if persistent storage the contains the given [card].
  Future<bool> containsCard(Card card) async {
    _checkInit();

    return _prefs.containsKey(_keyForSP(card));
  }

  T _convertValueToDb<T extends Object>(Card<T?> card, Object value) {
    final Object result = _getConverter(card)?.to(value) ?? value;

    switch (card.type) {
      case DataType.bool:
        return (result as bool) as T;
      case DataType.int:
        return (result as int) as T;
      case DataType.double:
        return (result as double) as T;
      case DataType.string:
        return (result as String) as T;
      case DataType.stringList:
        return ((result as List).cast<String>()) as T;
    }
  }

  /// Acts according to the [SharedPreferences.setMockInitialValues] method of the same name.
  @visibleForTesting
  void setMockInitialValues(Map<Card<Object?>, Object> values) {
    assert(checkConfiguration(_config));

    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({
      for (final MapEntry<Card<Object?>, Object> entry in values.entries)
        _keyForSP(entry.key): _convertValueToDb(entry.key, entry.value)
    });
  }

  /// Acts according to the [AccessToSP.getEntries] method of the same name.
  ///
  /// Returns all stored entities from the persistent storage.
  Map<Card, Object> getStoredEntries() {
    _checkInit();

    return {for (final Card card in getCards()) card: _getValueFromDb(card)!};
  }

  void _checkInit() => checkInit(_isInitialized, _config.name);
}

/// Get access to all the original methods of the [SharedPreferences] library.
///
/// Sometimes can be useful for debugging/testing or for use outside the system [Cardoteka].
mixin AccessToSP on Cardoteka {
  SharedPreferences get prefs {
    _checkInit();

    return Cardoteka._prefs;
  }

  /// The original [SharedPreferences.setPrefix] method.
  void setPrefix(String prefix) => SharedPreferences.setPrefix(prefix);

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
