import 'dart:async';

import 'package:meta/meta.dart';

import '../card.dart';
import '../core/cardoteka_core.dart';
import '../watcher.dart';

// ignore_for_file: prefer_function_declarations_over_variables

/// Signature for callbacks that report that a new value has been set in the storage.
typedef ValueCallback<V extends Object?> = void Function(V value);

/// Signature informs that the `onDetach` function should be called when
/// the listener is no longer needed. This will remove the linked resources.
typedef Detacher = void Function(void Function() onDetach);

/// Provides the ability to listen for new [Card] values when their value
/// changes in storage.
///
/// To use, simply mix this class to your [CardotekaCore] instance:
/// ```dart
/// class MyCardoteka extends Cardoteka with WatcherImpl {...}
///
/// // and then...
///
/// final cardoteka = MyCardoteka(...);
/// final actualValue = cardoteka.attach(
///   card,
///   onChange: (value) {...},
///   onRemove: () {...}
///   detacher: (onDetach) {...},
/// );
/// ```
base mixin WatcherImpl on CardotekaCore implements Watcher {
  @override
  @internal
  Watcher get watcher => this;

  /// A collection of [Card]s and callbacks associated with it.
  late final _watchers = <Card, List<ValueCallback>>{};

  @override
  @internal
  @protected
  @visibleForTesting
  void notify<V extends Object?>(Card<V> card, V value) {
    final List<ValueCallback<V?>>? callbacksByCard = _watchers[card];

    if (callbacksByCard != null) {
      for (final cb in callbacksByCard) {
        cb.call(value);
      }
    }
  }

  @override
  Future<void> notifyAll() async {
    final Iterable<Card> allWatcherCards = _watchers.keys;

    if (allWatcherCards.isNotEmpty) {
      for (final card in allWatcherCards) {
        notify(card, getOrNull(card));
      }
    }
  }

  /// Attach a [ValueCallback] to your [Card]. The [onChange] and [onRemove]
  /// parameters will allow you to track changes to the value in the storage.
  ///
  /// The [onChange] will be called whenever the [CardotekaCore.set] or
  /// [CardotekaCore.setOrNull] methods are called.
  ///
  /// The [onRemove] will be called whenever the [CardotekaCore.remove] or
  /// [CardotekaCore.removeAll] methods are called.
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
  ///   onChange: (value) => notifier.value = value,
  ///   onRemove: () => notifier.value = card.defaultValue,
  ///   detacher: notifier.onDispose, // attention to this line
  ///   fireImmediately: true,
  /// );
  /// ```
  ///
  /// For `ChangeNotifier` and its successors, use the [DetacherChangeNotifier] mixin:
  /// ```dart
  /// class ActivityNotifier with ChangeNotifier, DetacherChangeNotifier {...}
  /// ```
  ///
  /// For any other notifiers and BLoC-classes, use the [Detachability] mixin.
  ///
  /// The call will return the stored value from storage. If there was no value,
  /// [Card.defaultValue] will be returned.
  ///
  /// Note: however, in the case of [CardotekaAsync], the first value will always
  /// be [Card.defaultValue] and the actual value will be returned via [onChange].
  /// This behavior may change in the future:
  /// - https://github.com/PackRuble/cardoteka/issues/38
  ///
  /// If [fireImmediately] is set to true, the passed [onChange] will be executed
  /// immediately with stored value from storage or defaultValue if the value
  /// does not exist in storage. If the [Card.defaultValue] for the [Card]
  /// was null, [onRemove] will be called instead of [callback].
  /// Note: for [CardotekaAsync] `fireImmediately` is always true.
  V attach<V extends Object?>(
    Card<V> card, {
    required ValueCallback<V> onChange,
    required void Function()? onRemove,
    required Detacher detacher,
    bool fireImmediately = false,
  }) {
    final newCallback = (Object? value) => value == null
        ? onRemove?.call()
        // we create a new callback based on an existing one because
        // type 'void Function(V)' can't be assigned
        //   to 'void Function(Object?)'
        : onChange(value as V);

    final callbacksByCard =
        _watchers.putIfAbsent(card, () => <ValueCallback>[]);
    callbacksByCard.add(newCallback);

    detacher.call(() {
      callbacksByCard.remove(newCallback);
      if (callbacksByCard.isEmpty) {
        _watchers.remove(card);
      }
    });

    // issue(08.02.2025): [The `Watcher.attach` for `CardotekaAsync` instance first value returns a default value · Issue #38 · PackRuble/cardoteka](https://github.com/PackRuble/cardoteka/issues/38)
    // ignore: discarded_futures
    final FutureOr<V?> valueOr = getOrNull(card);
    if (valueOr is! Future<V?>) {
      final V result = valueOr as V ?? card.defaultValue;
      if (fireImmediately) onChange(result);
      return result;
    } else {
      unawaited(valueOr.then((value) {
        onChange(value ?? card.defaultValue);
      }));
      return card.defaultValue;
    }
  }
}

// fixdep(1.12.2023): [Allow mixins in "extends" clauses · Issue #1942 · dart-lang/language](https://github.com/dart-lang/language/issues/1942)
//
// `mixin WatcherImplDebug extends WatcherImpl {}`
// and then...
// `class CardotekaImpl extends Cardoteka with WatcherImplDebug {}`
@visibleForTesting
@internal
base mixin WatcherImplDebug on WatcherImpl {
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
