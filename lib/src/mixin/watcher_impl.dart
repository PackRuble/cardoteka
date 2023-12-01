import 'package:meta/meta.dart';

import '../card.dart';
import '../core.dart';
import '../watcher.dart';

// ignore_for_file: prefer_function_declarations_over_variables

/// Signature for callbacks that report that a new value has been set in the storage.
typedef ValueCallback<V extends Object?> = void Function(V value);

/// Signature for callbacks that report that
typedef Detacher = void Function(void Function());

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
  ///
  /// The call will return the stored value from storage. If there was no value,
  /// [Card.defaultValue] will be returned.
  ///
  /// If [fireImmediately] is set to true, the passed callback will be executed
  /// immediately with stored value from storage.
  ///
  V attach<V extends Object?>(
    Card<V> card,
    ValueCallback<V> callback, {
    required Detacher detacher,
    bool fireImmediately = false,
  }) {
    // we create a new callback based on an existing one because
    // type 'void Function(V)' can't be assigned
    //   to 'void Function(Object?)'
    final newCallback = (Object? value) => callback(value as V);
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

// todo:
// [Allow mixins in "extends" clauses](https://github.com/dart-lang/language/issues/1942)
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
