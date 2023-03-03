import 'i_card.dart';

/// The class provides the ability to track a changed value in the db.
abstract class IWatcher {
  /// Call to notify listeners.
  void notify<V>(ICard<V?> rKey, V value);
}
