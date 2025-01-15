import 'dart:async';
import 'dart:collection' show UnmodifiableListView;

import 'package:meta/meta.dart';

import '../card.dart';
import '../config.dart';
import '../converter.dart';
import '../watcher.dart';
import 'core_checks.dart' show checkConfiguration;

abstract base class CardotekaCore {
  /// Use this constructor to pass a configuration [CardotekaConfig] and create
  /// an instance of the [CardotekaCore].
  CardotekaCore({
    required this.config,
  }) :
        // fixdep(22.05.2023): this behavior is not yet available for const classes
        // https://github.com/dart-lang/language/issues/2581
        assert(checkConfiguration(config));

  /// List of [Card]'s for accessing the storage [SharedPreferencesAsync].
  UnmodifiableListView<Card> get cards => UnmodifiableListView(config.cards);

  /// Configuration file containing important information about the [Card]s.
  /// - [CardotekaConfig.name] is used to prefix the key in [SharedPreferencesAsync] for
  /// each of the [CardotekaAsync] instances;
  /// - [CardotekaConfig.cards] list of all card keys for accessing the storage.
  /// Access via [cards] if necessary.
  /// - [CardotekaConfig.converters] are used to convert a complex object to the base
  /// types defined in the [DataType] enumeration.
  @internal
  final CardotekaConfig config;

  /// Specify if listeners should be notified of new values in the persistence storage.
  ///
  /// Use a mixin based on the [Watcher] interface.
  @internal
  Watcher? get watcher => null;

  /// Get a [CardotekaConfig.name]-based key from the [config] and [Card.key] to use
  /// in the [SharedPreferencesAsync] storage.
  @internal
  String keyForSP(Card card) => '${config.name}.${card.key}';

  /// Get the converter for the [Card] card. Returns null if there is no converter.
  @internal
  Converter? getConverter(Card card) => config.converters?[card];

  FutureOr<V> get<V extends Object>(Card<V> card);

  FutureOr<V?> getOrNull<V extends Object?>(Card<V?> card);

  @internal
  FutureOr<V?> getValueFromSP<V>(Card<V?> card);

  Future<bool> set<V extends Object>(Card<V?> card, V value) async {
    watcher?.notify<V?>(card, value);

    return setValueToSP<V>(card, value);
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
      return setValueToSP<V>(card, value);
    }
  }

  @internal
  Future<bool> setValueToSP<V extends Object>(Card<V?> card, V value);

  @mustCallSuper
  Future<bool> remove(Card card) async {
    watcher?.notify(card, null);

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

  FutureOr<bool> containsCard(Card card);

  FutureOr<Set<Card>> getStoredCards();

  FutureOr<Map<Card, Object>> getStoredEntries();
}
