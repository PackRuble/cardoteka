// todo(20.02.2026, @PackRuble):
// import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:meta/meta.dart';

/// Signature of callbacks that have no arguments and return no data.
typedef VoidCallback = void Function();

/// Designed to be able to collect dispose-callbacks to execute later.
///
/// Convenient to use for state classes with dispose/close/etc. function
/// in conjunction with the [WatcherImpl.attach] method.
mixin class Detachability {
  List<VoidCallback>? _onDisposeCallbacks;

  /// Add a dispose-callback that will subsequently clean up the associated resources.
  void onDetach(void Function() cb) {
    _onDisposeCallbacks ??= [];
    _onDisposeCallbacks?.add(cb);
  }

  /// Calls all previously added dispose-callbacks and clears [_onDisposeCallbacks] list.
  @protected
  void detach() {
    _onDisposeCallbacks?.forEach((cb) => cb.call());
    _onDisposeCallbacks = null;
  }
}

/// Designed to be able to collect dispose-callbacks for [ChangeNotifier].
// mixin DetacherChangeNotifier on ChangeNotifier implements Detachability {
//   final _detachability = Detachability();
//
//   @override
//   void onDetach(void Function() cb) => _detachability.onDetach(cb);
//
//   @override
//   @protected
//   void detach() => _detachability.detach();
//
//   @override
//   @mustCallSuper
//   void dispose() {
//     detach();
//     super.dispose();
//   }
// }
