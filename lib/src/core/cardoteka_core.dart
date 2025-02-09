import 'dart:async';
import 'dart:collection' show UnmodifiableListView;

import 'package:meta/meta.dart';

import '../card.dart';
import '../config.dart';
import '../converter.dart';
import '../watcher.dart';
import 'core_checks.dart' show checkConfiguration;

/// {@template cardoteka.CardotekaCore}
/// A wrapper around the `shared_preferences` package that serves as a base class for subsequent `Cardoteka` specific implementations.
///
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
/// ```
///
/// And then in general terms:
/// ```dart
/// main() async {
///   final cardoteka = CardotekaAsync(
///     config: CardotekaConfig(
///       name: 'settings',
///       cards: SettingsCards.values,
///       converters: SettingsCards.converters,
///     ),
///   );
///
///   ThemeMode themeMode = await cardoteka.get(SettingsCards.themeMode); // will return default value
///   await cardoteka.set<ThemeMode>(SettingsCards.themeMode, ThemeMode.light);
///
///   themeMode = await cardoteka.get(SettingsCards.themeMode); // ThemeMode.light
///   await cardoteka.remove(SettingsCards.themeMode);
/// }
/// ```
///
/// To make it easier to understand what is happening, there is a “usage plan”:
///
/// 1. Define all values in [Card], using [Enum] to do so.
///   - implement the [Card] interface and define all required fields
///   - for each card, identify
///     - name (will be used as key. It shouldn't change after),
///     - <generic> for type designation for default value (optional)
///     - type to which the value will be converted. Select the appropriate one
///     from the [DataType] enumeration,
///     - default value. It will be returned when using [CardotekaCore.get],
///     if there were no saves in the storage for this card previously.
///   - converters if generic type does not match your [Card.type]
///
/// 2. Define a class that extends from an inheritor of the [CardotekaCore] class
/// (synchronous or asynchronous versions). Either pass the configuration
/// directly to the super class, or use required parameters.
/// At this stage you can also add the necessary [mixin]s to extend
/// the functionality of your cardoteka:
/// - [WatcherImpl] to implement listening for changes to values in your storage.
/// Use your implementation if necessary, extending from [Watcher].
/// - [CRUD] to use familiar basic CRUD operations (create, read, update, delete).
/// This is nothing more than an imitation based on the [CardotekaCore.get],
/// [CardotekaCore.set] and [CardotekaCore.remove] methods.
///
/// 3. Perform initialization (required for synchronous version) and take advantage of
/// all the features of your cardoteka! Save, read, delete, listen to your saved
/// data using typed cards.
///
/// Don't worry! If you do something wrong, you will receive a detailed
/// correction message in the console.
/// {@endtemplate}
abstract base class CardotekaCore {
  /// {@template cardoteka.CardotekaCore.constructor}
  /// Use this constructor to pass a configuration [CardotekaConfig]
  /// {@endtemplate}
  CardotekaCore({
    required this.config,
  }) :
        // fixdep(22.05.2023): this behavior is not yet available for const classes
        // [Allow run-time-only assertion checking in constant constructors · Issue #2581 · dart-lang/language](https://github.com/dart-lang/language/issues/2581)
        assert(checkConfiguration(config));

  /// List of [Card]'s for accessing the storage.
  UnmodifiableListView<Card> get cards => UnmodifiableListView(config.cards);

  /// Configuration file containing important information about the [Card]s.
  /// - [CardotekaConfig.name] is used to prefix the key in storage for
  /// each of the [CardotekaCore] instances;
  /// - [CardotekaConfig.cards] list of all card keys for accessing the storage.
  /// Access via [cards] if necessary.
  /// - [CardotekaConfig.converters] are used to convert a complex object to the base
  /// types defined in the [DataType] enumeration.
  @internal
  @protected
  final CardotekaConfig config;

  /// Specify if listeners should be notified of new values in storage.
  ///
  /// Use a mixin based on the [Watcher] interface.
  @internal
  @protected
  @visibleForTesting
  Watcher? get watcher => null;

  /// Get a [CardotekaConfig.name]-based key from the [config] and [Card.key]
  /// to use in storage.
  @internal
  @protected
  String getStorageKey(Card card) => '${config.name}.${card.key}';

  /// Get converter for the [Card] card. Returns null if there is no converter.
  @internal
  @protected
  Converter? getConverter(Card card) => config.converters?[card];

  /// {@template cardoteka.CardotekaCore.get}
  /// Get value from storage using [Card]<[Object]>.
  ///
  /// The default behavior assumes that if in storage does not have
  /// a record with the provided card, then `defaultValue` will be returned.
  ///
  /// The returned object is always non-nullable.
  ///
  /// If you need to return a null-value when there is no record in storage
  ///   OR
  /// your card is of nullable type [Card]<[Object?]>,
  ///   then use the [getOrNull] method.
  /// {@endtemplate}
  FutureOr<V> get<V extends Object>(Card<V> card);

  /// Get value from storage using [Card]<[Object?]>.
  ///
  /// If the record was not in the storage, then null will be returned. If you
  /// need to return a default value [Card.defaultValue] when there is no record
  /// in storage, use the [get] method.
  FutureOr<V?> getOrNull<V extends Object?>(Card<V?> card);

  /// Internal method to retrieve data from storage.
  @internal
  @protected
  FutureOr<V?> getValueFromStorage<V>(Card<V?> card);

  /// {@template cardoteka.CardotekaCore.set}
  /// Save new value in storage using [Card].
  ///
  /// {@template cardoteka.note_specify_generic}
  /// NOTE: Always specify a generic type and do so according to the type
  /// of your [Card.defaultValue]. This will help prevent compilation errors
  /// because without specifying a generic type, a type will be output
  /// based on the [card] provided and the stored [value].
  /// {@endtemplate}
  ///
  /// What you need to know:
  /// - type of [card] and [value] must match.
  /// - [value] cannot be `null`. Use [setOrNull] when you want if you want
  /// to simulate storing null.
  /// - [watcher] will be notified anyway (if it is not null).
  ///
  /// If successful, it will return true.
  /// {@endtemplate}
  Future<bool> set<V extends Object>(Card<V?> card, V value) async {
    watcher?.notify<V?>(card, value);

    return setValueToStorage<V>(card, value);
  }

  /// Save new value in storage using [Card], which can be of nullable type
  /// for [Card.defaultValue]. This method allows you to simulate saving
  /// of nullable values by saving or deleting them from storage. It means:
  /// - if you set null for a given [card] then the value will be removed
  /// from storage
  /// - any other value will be saved as usual.
  ///
  /// {@macro cardoteka.note_specify_generic}
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
      return await remove(card);
    } else {
      watcher?.notify<V?>(card, value);
      return setValueToStorage<V>(card, value);
    }
  }

  /// Internal method to save data in storage.
  ///
  /// Returns true if the value was successfully saved.
  @internal
  @protected
  Future<bool> setValueToStorage<V extends Object>(Card<V?> card, V value);

  /// Internal method to save object in storage.
  /// The [V] can be a type:
  /// - [bool]
  /// - [int]
  /// - [double]
  /// - [String]
  /// - [List]<[String]>
  ///
  /// Returns null if [V] is an invalid type.
  ///
  /// Returns true if the value was successfully saved.
  @internal
  Future<bool?> setObjectToStorage<V extends Object>(String key, V value);

  /// Internal method to get object from storage. The returned value can be:
  /// - [bool]
  /// - [int]
  /// - [double]
  /// - [String]
  /// - [List]<[String]>
  @internal
  FutureOr<Object?> getObjectFromStorage(String key, DataType type);

  /// {@template cardoteka.CardotekaCore.remove}
  /// Removes an entry by using [card] from storage.
  /// The [watcher] will be notified anyway (if it is not null).
  ///
  /// If successful, it will return true.
  /// {@endtemplate}
  Future<bool> remove(Card card);

  /// Iteratively removes all values associated with the provided [cards]
  /// from storage.
  ///
  /// The [watcher] will be notified anyway (if it is not null).
  ///
  /// Returns true only if the result was true for each card.
  Future<bool> removeAll() async {
    final results = await Future.wait([for (final card in cards) remove(card)]);
    final overallResult = results.fold(true, (prev, el) => prev && el);
    return overallResult;
  }

  /// {@template cardoteka.CardotekaCore.containsCard}
  /// Returns true if storage contains the given [card].
  /// {@endtemplate}
  FutureOr<bool> containsCard(Card card);

  /// {@template cardoteka.CardotekaCore.getStoredCards}
  /// Returns all [cards] that contains in the persistent storage.
  /// {@endtemplate}
  FutureOr<Set<Card>> getStoredCards();

  /// {@template cardoteka.CardotekaCore.getStoredCards}
  /// Returns all stored entities from storage.
  /// {@endtemplate}
  FutureOr<Map<Card, Object>> getStoredEntries();

  @override
  String toString() => '$runtimeType('
      '\n  config=$config,'
      '\n  watcher=$watcher,'
      '\n)';
}
