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

Future<void> main() async {
  await Cardoteka.init();
  // ignore_for_file: definitely_unassigned_late_local_variable
  // to☝️do: create an instance of cardoteka and pass configuration with cards
  late CardotekaImpl cardoteka;
  late Card<String> card; // with default value = 'no business...'

  final notifier = CurrentTaskNotifier('');
  cardoteka.attach(
    card,
    (value) {
      notifier.value = value;
      print('New case: $value');
    },
    detacher: notifier.onDispose, // attention to this line
  );

  await cardoteka.set(card, 'new case available!');
  // 1. console-> New case: no business...
  // 2. a value was saved to storage
  // 3. console-> New case: new case available!
}
