import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_db/reactive_db.dart';

class DbUser extends DbBase with Watcher {}

/// Storage of [Enum] type with possibility of using custom key.
enum KeyStore1<T> implements RKey<T> {
  counter<int>(TypeSaved.int, 0),
  counterCustom<int>(TypeSaved.int, 2, 'custom_counter'),
  ;

  const KeyStore1(this.type, this.defaultValue, [this._customKey]);

  @override
  final TypeSaved type;

  @override
  final T defaultValue;

  final String? _customKey;

  @override
  String get key => _customKey ?? EnumName(this).name;
}

final dbProvider = Provider<DbUser>((ref) {
  // ref.listenSelf((_, next) {
  //   if (!next.isInitialized) {
  //     print('${next.isInitialized}');
  //     ref.state.init(OurStoreKey.values);
  //   }
  // });
  ref.onDispose(() {
    // ref.state.notifier.dispose();
  });
  return DbUser();
});

final counterProvider = Provider.autoDispose<int>((ref) {
  print('init <counterProvider>');

  final db = ref.watch(dbProvider);

  return db.watcher.listen<int>(
    KeyStore1.counter,
    (value) {
      print('<counterProvider>: ${ref.state} -> $value');
      ref.state = value;
    },
    ref.onDispose,
  );
});

main() async {
  final container = ProviderContainer();

  final DbBase db = await container.read(dbProvider).init(KeyStore1.values);

  print(db);

  runApp(UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(
      home: Home(),
    ),
  ));
}

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('## build $Home');

    final controller = ref.watch(HomeController.instance);

    final dbController = ref.watch(dbProvider);

    List someList = List.generate(50, (index) => index);

    return Scaffold(
      appBar: AppBar(
        title: Text('appbarTitle'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Get watchers'),
            onTap: () => print(dbController.watcher.state),
          ),
          for (var o in someList) ListTile(title: Text(o.toString())),
          const CounterWidget(),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            onPressed: () {
              final data = ref.read(dbProvider).getSavedData();
              print(data);
            },
            child: const Icon(Icons.dataset),
          ),
          FloatingActionButton(
            onPressed: () =>
                controller.saveValue(ref.read(counterProvider) + 1),
            child: const Icon(Icons.add),
          ),
          TextButton(
              onPressed: () => ref.read(HomeController.instance).reloadDb(),
              child: const Text('Reload Db')),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class CounterWidget extends ConsumerWidget {
  const CounterWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('## build $CounterWidget');

    final counter = ref.watch(counterProvider);

    return ListTile(
      title: Text('You tapped the FAB $counter times'),
    );
  }
}

/// Class represent controller.
class HomeController {
  HomeController(Ref ref) {
    _ref = ref;
  }

  static late final Ref _ref;

  static WatcherNotifier get db => _ref.watch(dbProvider).watcher;

  static final counterProvider = Provider.autoDispose<int>((ref) {
    return db.listen<int>(
      KeyStore1.counter,
      (value) => ref.state = value,
      ref.onDispose,
    );
  });

  /// Instance of class [HomeController].
  static final instance = Provider.autoDispose(
    HomeController.new,
    name: '$HomeController',
  );

  void saveValue(int value) =>
      _ref.read(dbProvider).set(KeyStore1.counter, value);

  void reloadDb() => _ref.refresh(dbProvider).init(KeyStore1.values);
}
