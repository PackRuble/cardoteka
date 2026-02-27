import 'dart:async';
import 'dart:collection' show UnmodifiableListView;

import 'package:meta/meta.dart';

import '../card.dart';
import '../config.dart';
import '../converter.dart';
import '../data_type.dart';
import '../watcher.dart';
import 'core_checks.dart' show checkConfiguration;

/// {@template cardoteka.CardotekaCore}
/// A generic interface for synchronous, asynchronous and other implementations
/// of `Cardoteka`.
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
// todo(20.02.2026, @PackRuble):
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
///     - `<generic>` for type designation for default value (optional)
///     - type to which the value will be converted. Select the appropriate one
///     from the [DataType] enumeration,
///     - default value. It will be returned when using [CardotekaCore.getOrDefault],
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
/// This is nothing more than an imitation based on the [CardotekaCore.getOrDefault],
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
        assert(
          checkConfiguration(config),
          'The configuration contains errors.',
        );

  /// List of [Card]'s for accessing the storage.
  UnmodifiableListView<Card> get cards => UnmodifiableListView(config.cards);

  /// {@macro cardoteka.CardotekaConfig}
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

  /// Get converter for the [Card]. Returns null if there is no converter.
  @internal
  @protected
  Converter? getConverter(Card card) => config.converters?[card];

  /// {@template cardoteka.CardotekaCore.getOrNull}
  /// Get value from storage using [Card]<[V]?>.
  ///
  /// If the record was not in the storage, then null will be returned. If you
  /// need to return a default value [Card.defaultValue] when there is no record
  /// in storage, use the [getOrDefault] method.
  /// {@endtemplate}
  FutureOr<V?> get<V extends Object?>(Card<V> card);

  /// {@template cardoteka.CardotekaCore.get}
  /// Get value from storage using [Card]<[V]>.
  ///
  /// The default behavior assumes that if in storage does not have
  /// a record with the provided card, then [Card.defaultValue] will be returned.
  ///
  /// The returned object is always non-nullable.
  ///
  /// If you need to return a null-value when there is no record in storage
  ///   OR
  /// your card is of nullable type [Card]<[V]?>,
  ///   then use the [get] method.
  /// {@endtemplate}
  FutureOr<V> getOrDefault<V extends Object?>(Card<V> card);

  /// Internal method to retrieve data from storage.
  @internal
  @protected
  FutureOr<V?> getValueFromStorage<V extends Object?>(Card<V> card);

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
  /// - types [Card.type] and [value] must match;
  /// - [value] cannot be `null`. Use [setOrNull] when you want if you want
  /// to simulate storing null;
  /// - [watcher] will be notified anyway (if it is not null).
  ///
  /// If successful, it will return true.
  /// {@endtemplate}
  // is required to explicitly specify that the method to be implemented can be
  // either synchronous or asynchronous, while returning void
  // ignore_for_file: avoid_futureor_void
  FutureOr<void> set<V extends Object?>(Card<V> card, V value) async {
    watcher?.notify<V>(card, value);

    await setValueToStorage<V>(card, value);
  }

  /// Internal method to save data in storage.
  ///
  /// Returns true if the value was successfully saved.
  @internal
  @protected
  FutureOr<void> setValueToStorage<V extends Object?>(Card<V> card, V value);

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
  FutureOr<void> setObjectToStorage<V extends Object>(String key, V? value);

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
  FutureOr<void> remove(Card card);

  /// Iteratively removes all values associated with the provided [cards]
  /// from storage.
  ///
  /// The [watcher] will be notified anyway (if it is not null).
  ///
  /// Returns true only if the result was true for each card.
  // todo(21.02.2026, @PackRuble): add onlyKeys
  FutureOr<void> removeAll();

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
  String toString() => ''
      '$runtimeType('
      '\n  config=$config,'
      '\n  watcher=$watcher,'
      '\n)';
}
