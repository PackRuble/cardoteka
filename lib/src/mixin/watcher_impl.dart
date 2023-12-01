import 'package:meta/meta.dart';

import '../card.dart';
import '../core.dart';
import '../watcher.dart';

// ignore_for_file: prefer_function_declarations_over_variables


typedef ValueCallback<V extends Object?> = void Function(V value);

typedef Detacher = void Function(void Function());

/// Provides methods to be able to listen for changes in the database.
mixin WatcherImpl on Cardoteka implements Watcher {
  @override
  Watcher get watcher => this;

  final _watchers = <Card, List<ValueCallback>>{};

  @override
  @internal
  void notify<V extends Object>(Card<V?> card, V? value) {
    final List<ValueCallback<V?>>? callbacksByCard = _watchers[card];

    if (callbacksByCard != null) {
      for (final cb in callbacksByCard) {
        cb.call(value);
      }
    }
  }

  /// Attach a [ValueCallback] to your [Card]. A [callback] will be called
  /// whenever the [card] value changes.
  ///
  /// Use this method when you want to track changes in the value for [card].
  /// As soon as you call:
  /// - [Cardoteka.set] or [Cardoteka.setOrNull]
  /// - [Cardoteka.remove] or [Cardoteka.removeAll]
  /// the value is passed to the listener [callback].
  ///
  /// If your listener can be deleted, pass [detacher], thereby freeing up
  /// related resources. The necessity of this argument is due to the high degree
  /// of forgetfulness of its instruction.
  ///
  /// The call will return the stored value from storage. If there was no value,
  /// [Card.defaultValue] will be returned.
  ///
  /// If [fireImmediately] is set to true, the passed callback will be executed
  /// immediately.
  ///
  V attach<V extends Object?>(
    Card<V> card,
    ValueCallback<V> callback, {
    required Detacher? detacher,
    bool fireImmediately = false,
  }) {
    // we create a new callback based on an existing one because
    // type 'void Function(V)' can't be assigned
    //   to 'void Function(Object?)'
    final newCallback = (Object? value) => callback(value as V);
    final callbacksByCard =
        _watchers.putIfAbsent(card, () => <ValueCallback>[]);
    callbacksByCard.add(newCallback);

    detacher?.call(() {
      callbacksByCard.remove(newCallback);
      if (callbacksByCard.isEmpty) {
        _watchers.remove(card);
      }
    });

    final V value = getOrNull(card) ?? card.defaultValue;
    if (fireImmediately) newCallback.call(value);
    return value;
  }
}

@visibleForTesting
mixin WatcherImplDebug on WatcherImpl {
  @visibleForTesting
  Map<Card, List<ValueCallback>> get watchersDebug => _watchers;

  @visibleForTesting
  void printAllWatchers() {
    final buffer = StringBuffer();

    for (final entry in _watchers.entries) {
      buffer.writeln('Key: ${entry.key}, Listeners: ${entry.value}');
    }

    if (buffer.isEmpty) buffer.writeln('There are no listeners.');

    // ignore: avoid_print
    print('''
All listeners are represented at the moment:
$buffer''');
  }
}
