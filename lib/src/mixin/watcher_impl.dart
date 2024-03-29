import 'package:meta/meta.dart';

import '../card.dart';
import '../core.dart';
import '../watcher.dart';

// ignore_for_file: prefer_function_declarations_over_variables

/// Signature for callbacks that report that a new value has been set in the storage.
typedef ValueCallback<V extends Object?> = void Function(V value);

/// Signature informs that the onDetach function should be called when
/// the listener is no longer needed. This will remove the linked resources.
typedef Detacher = void Function(void Function() onDetach);

/// Provides the ability to listen for new [Card] values when their value
/// changes in storage.
///
/// To use, simply mix this class to your [Cardoteka] instance:
/// ```dart
/// class MyCardoteka extends Cardoteka with WatcherImpl {...}
///
/// // and then...
///
/// final cardoteka = MyCardoteka(...);
/// final actualValue = cardoteka.attach(
///   card,
///   (value) {...},
///   detacher: (onDetach) {...},
/// );
/// ```
mixin WatcherImpl on Cardoteka implements Watcher {
  @override
  @internal
  Watcher get watcher => this;

  final _watchers = <Card, List<ValueCallback>>{};

  @override
  @internal
  void notify<V extends Object?>(Card<V> card, V value) {
    final List<ValueCallback<V?>>? callbacksByCard = _watchers[card];

    if (callbacksByCard != null) {
      for (final cb in callbacksByCard) {
        cb.call(value);
      }
    }
  }

  /// Attach a [ValueCallback] to your [Card]. The [callback] and [onRemove]
  /// parameters will allow you to track changes to the value in the storage.
  ///
  /// The [callback] will be called whenever the [Cardoteka.set] or
  /// [Cardoteka.setOrNull] methods are called.
  ///
  /// The [onRemove] will be called whenever the [Cardoteka.remove] or
  /// [Cardoteka.removeAll] methods are called.
  ///
  /// Pass [detacher] to remove the watcher when it becomes irrelevant.
  /// The meaning of this functionality can be described as follows:
  /// ```dart
  /// class MyNotifier extends ValueNotifier {
  ///   MyNotifier(super._value);
  ///
  ///   VoidCallback? _onDetach;
  ///   void onDispose(void Function() cb) => _onDetach = cb;
  ///
  ///   @override
  ///   void dispose() {
  ///     _onDetach?.call();
  ///     super.dispose();
  ///   }
  /// }
  ///
  /// // then...
  ///
  /// final notifier = MyNotifier(0);
  ///
  /// cardoteka.attach(
  ///   card,
  ///   (value) => notifier.value = value,
  ///   detacher: notifier.onDispose, // attention to this line
  ///   fireImmediately: true,
  /// );
  /// ```
  /// A repeated call to _onDetach is completely safe.
  ///
  /// The call will return the stored value from storage. If there was no value,
  /// [Card.defaultValue] will be returned.
  ///
  /// If [fireImmediately] is set to true, the passed [callback] will be executed
  /// immediately with stored value from storage or defaultValue if the value
  /// does not exist in storage. If the [Card.defaultValue] for the [Card]
  /// was null, [onRemove] will be called instead of [callback].
  V attach<V extends Object?>(
    Card<V> card,
    ValueCallback<V> callback, {
    void Function()? onRemove,
    required Detacher detacher,
    bool fireImmediately = false,
  }) {
    final newCallback = (Object? value) => value == null
        ? onRemove?.call()
        // we create a new callback based on an existing one because
        // type 'void Function(V)' can't be assigned
        //   to 'void Function(Object?)'
        : callback(value as V);

    final callbacksByCard =
        _watchers.putIfAbsent(card, () => <ValueCallback>[]);
    callbacksByCard.add(newCallback);

    detacher.call(() {
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

// fixdep(1.12.2023): Allow mixins in "extends" clauses
// https://github.com/dart-lang/language/issues/1942
//
// mixin WatcherImplDebug extends WatcherImpl {}
// and then...
// class CardotekaImpl extends Cardoteka with WatcherImplDebug {}

@visibleForTesting
@internal
mixin WatcherImplDebug on WatcherImpl {
  @visibleForTesting
  @internal
  Map<Card, List<ValueCallback>> get watchersDebug => _watchers;

  @visibleForTesting
  @internal
  String getWatchers([bool console = false]) {
    final buffer = StringBuffer();

    if (watchersDebug.entries.isNotEmpty) {
      for (final entry in watchersDebug.entries) {
        buffer.writeln(
            '-> for [${entry.key}] there are [${entry.value.length}] listeners');
      }
    } else {
      buffer.writeln('There are no listeners.');
    }

    if (console) {
      // ignore: avoid_print
      print('''
All listeners are represented at the moment:
$buffer''');
    }

    return buffer.toString();
  }
}
