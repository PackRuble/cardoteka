import 'package:state_notifier/state_notifier.dart';

import 'core.dart';

// Todo: посмотреть, будут ли обновляться все провайдеры при обновлении одного значения.
// если будут, то тогда сложность O(n).
// по большому счету это задача слушателей фильтровать изменения.

/// Adds the ability to notify listeners of database changes.
mixin Watcher on DbBase {
  final WatcherNotifier _watcher = WatcherNotifier();

  @override
  WatcherNotifier get watcher => _watcher;
}

class WatcherNotifier extends StateNotifier<Map<RKey, dynamic>> {
  WatcherNotifier() : super(const <RKey, dynamic>{});

  /// Update the state of the notifier if it needs to do so (i.e. is a listener).
  void addWatcher<T>(RKey<T> rKey, T value) {
    final bool isContain = state.containsKey(rKey);
    print('addWatcher - ${rKey.key}: $value - $isContain');
    print(state);

    if (isContain) {
      _updateState(rKey, value);
    }
  }

  /// Internal method for correctly updating the state with the new value.
  void _updateState(RKey rKey, value) {
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
    print('listen -> Watcher: ${rKey.key}');
    // state.update(storeKey, (_) => storeKey.defaultValue); // mistake
    // _updateState(storeKey, storeKey.defaultValue); // mistake

    // пополняем коллекцию новым значением. [updateShouldNotify] при этом решает,
    // что изменений не произошло
    state = {
      ...{rKey: rKey.defaultValue},
      ...state
    };

    // в дальнейшем данная функция будет срабатывать каждый раз,
    // когда происходит изменение состояния
    final remover = addListener(fireImmediately: false, (state) {
      final value = state[rKey] as T;

      cb.call(value);
    });

    onDispose?.call(() {
      print(this.hasListeners);
      print(this.state);
      print('<counterProvider> disposed');
      print(state.remove(rKey));
      remover.call();
      print(this.hasListeners);
      print(this.state);
    });

    return rKey.defaultValue;
  }
}
