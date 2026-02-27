import 'dart:async' show FutureOr;

extension FutureSync<V> on FutureOr<V> {
  /// Synchronous access when we are sure of it.
  V sync() => this as V;
}
