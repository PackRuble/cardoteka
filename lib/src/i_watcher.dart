import 'i_card.dart';

/// The class provides the ability to track a changed value in the db.
abstract class IWatcher {
  /// Call to notify listeners.
  void notify<V extends Object>(ICard<V?> card, V? value);
}
