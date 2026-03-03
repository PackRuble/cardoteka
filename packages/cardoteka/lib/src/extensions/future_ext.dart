import 'dart:async' show FutureOr;

// todo(03.03.2026, @PackRuble): contaminates the user's workspace because it applies to all objects. Remove and prompt the user to use `as`
extension FutureSync<V> on FutureOr<V> {
  /// Synchronous access when we are sure of it.
  V sync() => this as V;
}
