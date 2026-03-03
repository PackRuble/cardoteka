import 'dart:async';

import 'package:meta/meta.dart';

import '../card.dart';
import '../core/cardoteka_core.dart';
import '../watcher.dart';

//
// ignore_for_file: prefer_function_declarations_over_variables

/// Signature for callbacks that report that a new value has been set in the storage.
typedef ChangeValueCallback<V extends Object?> = void Function(V value);

/// Signature for callbacks that report that a record has been removed from storage.
typedef RemoveRecordCallback = void Function();

/// A record of callbacks with notification of changes to the storage record.
@visibleForTesting
@internal
typedef RecordCallbacks = (ChangeValueCallback, RemoveRecordCallback?);

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
  late final _watchers = <Card, List<RecordCallbacks>>{};

  @override
  @internal
  @protected
  @visibleForTesting
  void notify<V extends Object?>(Card<V> card, V value) {
    final callbacksByCard = _watchers[card];

    if (callbacksByCard != null) {
      for (final cb in callbacksByCard) {
        cb.$1.call(value);
      }
    }
  }

  @override
  @internal
  @protected
  @visibleForTesting
  void notifyAboutRemove(List<Card> cards) {
    for (final card in cards) {
      final callbacksByCard = _watchers[card];

      if (callbacksByCard != null) {
        for (final cb in callbacksByCard) {
          cb.$2?.call();
        }
      }
    }
  }

  @override
  Future<void> notifyAll() async {
    final allWatcherCards = _watchers.keys;

    for (final card in allWatcherCards) {
      notify(card, get(card));
    }
  }

  /// Attach a [ChangeValueCallback] to your [Card]. The [onChange] and [onRemove]
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
    required ChangeValueCallback<V> onChange,
    required RemoveRecordCallback? onRemove,
    required Detacher detacher,
    bool fireImmediately = false,
  }) {
    // we create a new callback based on an existing one because
    // type 'void Function(V)' can't be assigned
    //   to 'void Function(Object?)'
    final onChangeCallback = (Object? value) => onChange(value as V);
    final onRemoveCallback = onRemove;
    final RecordCallbacks callbackRecord = (onChangeCallback, onRemoveCallback);

    final callbacksByCard = _watchers.putIfAbsent(card, () => []);
    callbacksByCard.add(callbackRecord);

    detacher.call(() {
      callbacksByCard.remove(callbackRecord);
      if (callbacksByCard.isEmpty) {
        _watchers.remove(card);
      }
    });

    // todo(08.02.2025, @PackRuble): #38 The `Watcher.attach` for `CardotekaAsync` instance first value returns a default value
    // todo(03.03.2026, @PackRuble): #45  Error: "type 'Null' is not a subtype of type 'String' in type cast" in WatcherImpl.attach
    final FutureOr<V?> valueOr = get(card);
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
  Map<Card, List<RecordCallbacks>> get watchersDebug => _watchers;

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
      //
      // ignore: avoid_print
      print('''
All listeners are represented at the moment:
$buffer''');
    }

    return buffer.toString();
  }
}
