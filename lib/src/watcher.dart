import 'package:meta/meta.dart';
import 'package:reactive_db/src/i_watcher.dart';
import 'package:state_notifier/state_notifier.dart';

import 'core.dart';
import 'i_rkey.dart';

/// Provides methods to be able to listen for changes in the database.
mixin Watcher on RDatabase implements IWatcher {
  late final _WatcherNotifier _notifier = _WatcherNotifier(super.get);

  @override
  @internal
  IWatcher get watcher => this;

  @override
  @visibleForTesting
  Map<RKey, dynamic> getWatchers() => _notifier.debugState;

  @override
  void actualizeValue<T>(RKey<T> rKey, T value) =>
      _notifier.addWatcher<T>(rKey, value);

  @override
  T listen<T>(
    RKey<T> rKey,
    Function(T value) cb, [
    void Function(void Function())? onDispose,
  ]) =>
      _notifier.listen(rKey, cb, onDispose);
}

class _WatcherNotifier extends StateNotifier<Map<RKey, dynamic>> {
  _WatcherNotifier(this.getSavedValue) : super(<RKey, dynamic>{});

  final T Function<T>(RKey<T> rKey) getSavedValue;

  /// Update the state of the notifier if it needs to do so (i.e. is a listener).
  void addWatcher<T>(RKey<T> rKey, T value) {
    final bool isContain = state.containsKey(rKey);
    print('addWatcher - ${rKey.key}: $value - $isContain');

    if (isContain) {
      _updateState(rKey, value);
    }
  }

  /// Internal method for correctly updating the state with the new value.
  void _updateState<T>(RKey<T> rKey, T value) {
    state[rKey] = value;
    state = {...state};
  }

  /// Adds a listener that will receive new values when the database state changes.
  ///
  /// Provide the [onDispose] method if your listener can be removed.
  T listen<T>(
    RKey<T> rKey,
    Function(T value) cb, [
    void Function(void Function())? onDispose,
  ]) {
    final T savedValue = getSavedValue.call<T>(rKey);

    // _updateState(rKey, rKey.defaultValue); // mistake  if state const map
    // state = {
    //   ...{rKey: savedValue},
    //   ...state
    // };

    // используем данный метод добавления, чтобы не запускать процесс изменения состояния
    // по сути, мутируем объект
    state.addAll({rKey: savedValue});

    // в дальнейшем данная функция будет срабатывать каждый раз,
    // когда происходит изменение состояния
    final remover = addListener(fireImmediately: false, (state) {
      final value = state[rKey] as T;

      cb.call(value);
    });

    onDispose?.call(() {
      state.remove(rKey);
      remover.call();
    });

    return savedValue;
  }
}
