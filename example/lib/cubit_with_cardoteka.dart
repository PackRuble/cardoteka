import 'package:bloc/bloc.dart';
import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:meta/meta.dart' show protected;

/// Perhaps this mixin will be included in the package in one form or another...
mixin Detachability {
  List<VoidCallback>? _onDisposeCallbacks;

  void onDetach(void Function() cb) {
    _onDisposeCallbacks ??= [];
    _onDisposeCallbacks!.add(cb);
  }

  @protected
  void detach() {
    _onDisposeCallbacks?.forEach((cb) => cb.call());
    _onDisposeCallbacks = null;
  }
}

class CubitImpl extends Cubit<int> with Detachability {
  CubitImpl(super.initialState);

  void setValue(int value) => emit(value);

  @override
  void onChange(Change<int> change) {
    super.onChange(change);
    print('Value has been changed:${change.currentState}->${change.nextState}');
  }

  @override
  Future<void> close() async {
    super.detach();
    return super.close();
  }
}

class CardotekaImpl = Cardoteka with WatcherImpl;

Future<void> main() async {
  await Cardoteka.init();
  // ignore_for_file: definitely_unassigned_late_local_variable
  // to☝️do: create an instance of cardoteka and pass configuration with cards
  late CardotekaImpl cardoteka;
  late Card<int> counterCard; // defaultValue = 99

  final cubit = CubitImpl(counterCard.defaultValue);
  cardoteka.attach(
    counterCard,
    cubit.setValue,
    detacher: cubit.onDetach,
  );

  await cardoteka.set(counterCard, 321);
  // 1. a value was saved to storage
  // 2. console-> Value has been changed:99->321
}
