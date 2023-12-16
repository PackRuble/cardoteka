import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db_provider.dart';

/// Показывает, каким образом можно использовать [RDatabase]

final bananaProvider = Provider.autoDispose<int>((ref) {
  final db = ref.watch(dbProvider);

  return db.attach<int>(
    KeyStore1.banana,
    (value) => ref.state = value,
    detacher: ref.onDispose,
  );
}, name: 'bananaProvider');

class BananaCounterWidget extends ConsumerWidget {
  const BananaCounterWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(bananaProvider);

    return Row(
      children: [
        Text('Bananas left - $count'),
        IconButton(
          onPressed: () =>
              ref.read(BananaControllerUI.instance).saveValue(count + 1),
          icon: const Icon(Icons.add),
        ),
      ],
    );
  }
}

/// Class represent controller.
class BananaControllerUI {
  BananaControllerUI(this._ref);

  final Ref _ref;

  DbUser get db => _ref.watch(dbProvider);

  /// You can even use watcher if you want, although it is preferable to use mixin [Watcher]
  static final bananaProvider = Provider.autoDispose<int>((ref) {
    return ref.watch(instance).db.attach<int>(
          KeyStore1.banana,
          (value) => ref.state = value,
          detacher: ref.onDispose,
        );
  });

  /// Instance of class [BananaControllerUI].
  static final instance = Provider(BananaControllerUI.new);

  /// Save value in database. Note how you can update [bananaProvider] using [RDatabase.listen] with [Watcher]
  void saveValue(int value) =>
      _ref.read(dbProvider).set(KeyStore1.banana, value);
}
