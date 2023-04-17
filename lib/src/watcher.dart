import 'package:meta/meta.dart';

import 'core.dart';
import 'i_card.dart';
import 'i_watcher.dart';

// ignore_for_file: prefer_function_declarations_over_variables

typedef CbWatcher<V> = void Function(V value);

typedef Detacher = void Function(void Function());

/// Provides methods to be able to listen for changes in the database.
mixin Watcher on CardDb implements IWatcher {
  @override
  IWatcher get watcher => this;

  final _watchers = <ICard, List<CbWatcher>>{};

  @visibleForTesting
  Map<ICard, List<CbWatcher>> debugGetWatchers() => _watchers;

  @override
  @internal
  void notify<V extends Object>(ICard<V?> card, V? value) {
    final ws = _watchers[card];

    if (ws != null) {
      for (final watcher in ws) {
        watcher.call(value);
      }
    }
  }

  /// Attach a [CbWatcher] to your [ICard]. A [watcher] will be called whenever
  /// the [card] value changes.
  ///
  /// Use this method when you want to track changes in the value for [card].
  /// As soon as you call [CardDb.set] the value is passed to the listener [watcher].
  /// If your listener can be deleted, pass [detacher], thereby freeing up related resources.
  ///
  /// The first call returns the stored value from the database. If null, returned
  /// default value [ICard.defaultValue] for the given [card].
  V attach<V extends Object?>(
    ICard<V> card,
    CbWatcher<V> watcher, {
    // The obligativeness of the argument [detacher] is due to the high degree
    //  of forgetfulness of its instruction
    required Detacher? detacher,
  }) {
    final w = (Object? value) => watcher(value as V);

    _watchers[card] = [...?_watchers[card], w];

    detacher?.call(() {
      _watchers[card]?.remove(w);

      // Remove the key from the [_watchers], if the list is empty
      if (_watchers[card]?.isEmpty ?? false) {
        _watchers.remove(card);
      }
    });

    return getOrNull(card) ?? card.defaultValue;
  }

  @visibleForTesting
  void printAllWatchers() {
    final buffer = StringBuffer();

    for (final entry in _watchers.entries) {
      buffer.writeln('Key: ${entry.key}, List of listeners: ${entry.value}');
    }

    if (buffer.isEmpty) buffer.writeln('There are no listeners.');

    print('''
All listeners are represented at the moment:
$buffer''');
  }
}
