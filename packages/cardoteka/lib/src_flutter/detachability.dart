import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:meta/meta.dart' show mustCallSuper, protected;

import '../src/mixin/detachability.dart' show Detachability;

/// Designed to be able to collect dispose-callbacks for [ChangeNotifier].
mixin DetacherChangeNotifier on ChangeNotifier implements Detachability {
  final _detachability = Detachability();

  @override
  void onDetach(void Function() cb) => _detachability.onDetach(cb);

  @override
  @protected
  void detach() => _detachability.detach();

  @override
  @mustCallSuper
  void dispose() {
    detach();
    super.dispose();
  }
}
