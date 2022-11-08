import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db_provider.dart';

/// Example shows how two ISPs work independently of each other using the [Watcher] mixin.

/// Class represent controller.
class CountersWidgetController {
  CountersWidgetController(this._ref);

  final Ref _ref;

  static final counter1Provider = Provider.autoDispose<int>((ref) {
    return ref.watch(dbProvider).listen<int>(
          KeyStore1.counter1,
          (value) => ref.state = value,
          ref.onDispose,
        );
  }, name: 'counter1Provider');

  static final counter2Provider = Provider.autoDispose<int>((ref) {
    return ref.watch(dbProvider).listen<int>(
          KeyStore1.counter2,
          (value) => ref.state = value,
          ref.onDispose,
        );
  }, name: 'counter2Provider');

  /// Instance of class [CountersWidgetController].
  static final instance = Provider.autoDispose(CountersWidgetController.new);
}

class CountersWidget extends ConsumerStatefulWidget {
  const CountersWidget({Key? key}) : super(key: key);

  @override
  ConsumerState<CountersWidget> createState() => _CountersWidgetState();
}

class _CountersWidgetState extends ConsumerState<CountersWidget> {
  bool isVisible1 = true;
  bool isVisible2 = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            TextButton(
              onPressed: () => setState(() => isVisible1 = !isVisible1),
              child: Text('Visible Counter1: $isVisible1'),
            ),
            TextButton(
              onPressed: () => ref.read(dbProvider).set(KeyStore1.counter1,
                  ref.read(CountersWidgetController.counter1Provider) + 1),
              child: Text('++ Counter1'),
            ),
            SizedBox(width: 15),
            TextButton(
              onPressed: () => setState(() => isVisible2 = !isVisible2),
              child: Text('Visible Counter2: $isVisible2'),
            ),
            TextButton(
              onPressed: () => ref.read(dbProvider).set(KeyStore1.counter2,
                  ref.read(CountersWidgetController.counter2Provider) + 3),
              child: Text('++ Counter2'),
            ),
          ],
        ),
        Visibility(
          visible: isVisible1,
          child: Consumer(
            builder: (_, WidgetRef ref, __) {
              print('##buildWidget counter1');

              final counter1 =
                  ref.watch(CountersWidgetController.counter1Provider);

              return Text('Counter1: $counter1');
            },
          ),
        ),
        Visibility(
          visible: isVisible2,
          child: Consumer(
            builder: (BuildContext context, WidgetRef ref, Widget? child) {
              print('##buildWidget counter2');

              final counter2 =
                  ref.watch(CountersWidgetController.counter2Provider);

              return Text('Counter2: $counter2');
            },
          ),
        ),
      ],
    );
  }
}
