import 'dart:async';

import 'package:meta/meta.dart';

import 'card.dart';

/// The class provides the ability to track changes to a value in the storage.
/// Implement your own class if necessary, or use [WatcherImpl].
///
/// The [Watcher.notify] method will be called whenever the value in the store
/// changes.
abstract interface class Watcher {
  /// Called whenever a new value is provided for the storage. To implement
  /// this method, please refer to the documentation [CardotekaCore.watcher].
  @internal
  void notify<V extends Object?>(Card<V> card, V value);

  /// Allows to notify all listeners with the new values.
  // classes implementing this interface must have this feature
  // ignore: avoid_futureor_void
  FutureOr<void> notifyAll();
}
