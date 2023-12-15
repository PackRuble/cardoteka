import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart' hide Card;

/// Example of using [Cardoteka] and [WatcherImpl] mixin with [ChangeNotifier].

/// Perhaps this mixin will be included in the package in one form or another...
mixin NotifierDetacher on ChangeNotifier {
  List<VoidCallback>? _onDisposeCallbacks;

  void onDispose(void Function() cb) {
    _onDisposeCallbacks ??= [];
    _onDisposeCallbacks!.add(cb);
  }

  @override
  void dispose() {
    _onDisposeCallbacks?.forEach((cb) => cb.call());
    _onDisposeCallbacks = null;

    super.dispose();
  }
}

/// A given notifier can have as many states as you like.
class OrderNotifier with ChangeNotifier, NotifierDetacher {
  final _orders = <String>[];

  void addOrder(String value) {
    _orders.add(value);
    notifyListeners();
    print('New order: $value');
  }
}

class CardotekaImpl = Cardoteka with WatcherImpl;

void main() {
  // ignore_for_file: definitely_unassigned_late_local_variable
  // to do: initialize
  late CardotekaImpl cardoteka;
  late Card<String> lastOrderCard;

  final notifier = OrderNotifier();
  cardoteka.attach(
    lastOrderCard,
    notifier.addOrder,
    detacher: notifier.onDispose,
  );

  cardoteka.set(lastOrderCard, '#341');
  // 1. a value was saved to storage
  // 2. console-> New order: #341
}
