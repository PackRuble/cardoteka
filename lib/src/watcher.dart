import 'package:meta/meta.dart';

import 'core.dart';
import 'i_card.dart';
import 'i_watcher.dart';

// ignore_for_file: prefer_function_declarations_over_variables

typedef CbWatcher<V> = void Function(V bait);

typedef Detacher = void Function(void Function());

/// Provides methods to be able to listen for changes in the database.
mixin Watcher on CardDb implements IWatcher {
  @override
  IWatcher get watcher => this;

  final _watchers = <ICard, List<CbWatcher>>{};

  Map<ICard, List<CbWatcher>> debugGetWatchers() => _watchers;

  @override
  @internal
  void notify<V>(ICard<V?> key, V value) {
    final ws = _watchers[key];

    if (ws != null) {
      for (final watcher in ws) {
        watcher.call(value);
      }
    }
  }

  /// Attach a [CbWatcher] to your [ICard]. A [watcher] will be called whenever
  /// the [key] value changes.
  ///
  /// Use this method when you want to track changes in the value for [key].
  /// As soon as you call [CardDb.set] the value is passed to the listener [watcher].
  /// If your listener can be deleted, pass [detacher], thereby freeing up related resources.
  /// The first call returns the default value [ICard.defaultValue] for the given [key].
  V attach<V>(
    ICard<V> key,
    CbWatcher<V> watcher, [
    Detacher? detacher,
  ]) {
    final w = (Object? food) => watcher(food as V);

    _watchers[key] = [...?_watchers[key], w];

    detacher?.call(() {
      _watchers[key]?.remove(w);

      // Remove the key from the [_watchers], if the list is empty
      if (_watchers[key]?.isEmpty ?? false) {
        _watchers.remove(key);
      }
    });

    return key.defaultValue;
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
