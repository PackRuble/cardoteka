import 'card.dart';

/// The class provides the ability to track a changed value in the persistence storage.
abstract class Watcher {
  /// Call to notify listeners.
  void notify<V extends Object>(Card<V?> card, V? value);
}
