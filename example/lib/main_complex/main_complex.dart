import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stack_trace/stack_trace.dart' as stack_trace;

import 'banana_count.dart';
import 'counters.dart';
import 'db_provider.dart';
import 'using_converter.dart';

Future main() async {
  FlutterError.demangleStackTrace = (StackTrace stack) {
    if (stack is stack_trace.Trace) return stack.vmTrace;
    if (stack is stack_trace.Chain) return stack.toTrace().vmTrace;
    return stack;
  };

  final container = ProviderContainer(observers: [Logger()]);

  final DbUser db = container.read(dbProvider);
  await db.init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const MaterialApp(
        home: Home(),
      ),
    ),
  );
}

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing RDatabase'),
      ),
      body: Stack(children: const [
        HomePage(),
        Align(
          alignment: Alignment.centerRight,
          child: HelperButtonsWidget(),
        ),
      ]),
    );
  }
}

class HelperButtonsWidget extends ConsumerWidget {
  const HelperButtonsWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(dbProvider);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          onPressed: () {
            final state = db.debugGetWatchers();
            print(state);
          },
          child: const Text('Get watchers'),
        ),
        TextButton(
            onPressed: () => ref.read(HomePageController.instance).reloadDb(),
            child: const Text('Reload Db')),
        TextButton(
            onPressed: () {
              final data = db.getSavedData();
              print(data);
            },
            child: const Text('Saved in prefs')),
      ],
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: const [
        BananaCounterWidget(),
        Divider(),
        CountersWidget(),
        Divider(),
        DataModelWidget(),
      ],
    );
  }
}

/// Class represent controller.
class HomePageController {
  HomePageController(this._ref);

  final Ref _ref;

  /// Instance of class [HomePageController].
  static final instance = Provider.autoDispose(HomePageController.new);

  /// Reload our database.
  void reloadDb() => _ref.refresh(dbProvider).init();
}

class Logger implements ProviderObserver {
  @override
  void didAddProvider(
          ProviderBase provider, Object? value, ProviderContainer container) =>
      print('AddProvider: $provider($value)');

  @override
  void didDisposeProvider(ProviderBase provider, ProviderContainer container) =>
      print('DisposeProvider: $provider');

  @override
  void didUpdateProvider(ProviderBase provider, Object? previousValue,
      Object? newValue, ProviderContainer container) {
    print('UpdateProvider: $provider($previousValue -> $newValue)');
  }

  @override
  void providerDidFail(ProviderBase provider, Object error,
      StackTrace stackTrace, ProviderContainer container) {
    print('Fail: $provider');
  }
}
