import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart' hide Card;

/// Example of using [Cardoteka] and [WatcherImpl] mixin with [ValueNotifier].

class CurrentTaskNotifier extends ValueNotifier {
  CurrentTaskNotifier(super.task);

  VoidCallback? _onDetach;

  void onDispose(void Function() cb) => _onDetach = cb;

  @override
  void dispose() {
    _onDetach?.call();
    super.dispose();
  }
}

class CardotekaImpl = Cardoteka with WatcherImpl;

void main() {
  // to do: initialize
  CardotekaImpl? cardoteka;
  Card<String>? card; // with default value = 'nothing to do now'

  final notifier = CurrentTaskNotifier('');
  cardoteka!.attach(
    card!,
    (value) {
      notifier.value = value;
      print('New case: $value');
    },
    detacher: notifier.onDispose, // attention to this line
    fireImmediately: true, // callback will fire immediately
  );

  cardoteka.set(card, 'new case available!');
  // 1. console-> nothing to do now
  // 2. a value was saved to storage
  // 3. console-> New case: new case available!
}
