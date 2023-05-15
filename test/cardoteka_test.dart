import 'package:cardoteka/cardoteka.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Storage of [Enum] type with possibility of using custom key.
enum FruitCard<T> implements Card<T> {
  banana<int>(DataType.int, 4),
  bananaNull<int?>(DataType.int, 4),
  counter1<int>(DataType.int, 0),
  counter2<int>(DataType.int, 0),
  counterCustom<int>(DataType.int, 2, 'custom_counter_key'),
  ;

  const FruitCard(this.type, this.defaultValue, [this.customKey]);

  @override
  final DataType type;

  @override
  final T defaultValue;

  final String? customKey;

  @override
  String get key => customKey ?? EnumName(this).name;
}

class DbUser extends Cardoteka with WatcherImpl {
  DbUser({required super.cards, required super.config});
}

final dbProvider = Provider<DbUser>(
  (ref) => DbUser(
    cards: FruitCard.values,
    config: const Config(name: 'FruitCard'),
  ),
);

const initCountBanana = 0;

final bananaProvider = Provider<int>((ref) {
  ref.watch(dbProvider).attach<int>(
        FruitCard.banana,
        (value) => ref.state = value,
        detacher: ref.onDispose,
      );

  return initCountBanana;
}, name: 'bananaProvider');

final bananaProviderWithAutoDispose = Provider.autoDispose<int>((ref) {
  final banana = ref.watch(dbProvider).attach<int>(
        FruitCard.banana,
        (value) => ref.state = value,
        detacher: ref.onDispose,
      );

  return banana;
}, name: 'bananaProvider');

void main() {
  // https://github.com/flutter/flutter/issues/98473
  // TestWidgetsFlutterBinding.ensureInitialized();
  // DartPluginRegistrant.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  test('Watcher', () async {
    final db = DbUser(
      cards: FruitCard.values,
      config: const Config(name: 'FruitCard'),
    );

    await db.init();

    late int newValue;

    final int value = db.attach(
      FruitCard.banana,
      (v) => newValue = v,
      detacher: null,
    );
    expect(
      db.debugGetWatchers(),
      contains(FruitCard.banana),
      reason: 'must be contain watcher after use [Watcher.attach]',
    );

    expect(
      value,
      FruitCard.banana.defaultValue,
      reason:
          'after use [Watcher.attach] we expect [ICard.defaultValue]:${FruitCard.banana.defaultValue}',
    );

    const newCount = 5;
    await db.set<int>(FruitCard.banana, newCount);
    expect(
      newCount,
      db.get(FruitCard.banana),
      reason: 'after call [DbCard.set] we expect newCount:$newCount',
    );

    expect(
      newValue,
      newCount,
      reason:
          'after call [DbCard.set] + before [Watcher.attach], we expect notify',
    );
  });

  test('Watcher+Riverpod($Provider)', () async {
    final container = ProviderContainer();

    final DbUser db = container.read(dbProvider);

    await db.init();

    expect(
      initCountBanana,
      container.read(bananaProvider),
      reason: 'init count banana in provider',
    );

    int newCount = 5;
    await db.set<int>(FruitCard.banana, newCount);
    expect(
      newCount,
      container.read(bananaProvider),
      reason: 'read after set new value in db',
    );

    // todo: лучше проверить на наличие конкретной функции onDispose();
    expect(
      db.debugGetWatchers().entries,
      hasLength(1),
      reason:
          'we use [Weather.attach] so bananaProvider must be contain in _watchers',
    );
    expect(
      db.debugGetWatchers()[FruitCard.banana],
      isNotNull,
    );

    container.dispose();
    expect(
      db.debugGetWatchers().entries,
      hasLength(0),
      reason:
          'Если bananaProvider утилизируется и при этом передает функцию ref.onDispose(),'
          ' то [Watcher] также должен быть утилизирован',
    );

    newCount = 12;
    await db.set<int>(FruitCard.banana, newCount);
    expect(
      newCount,
      db.get(FruitCard.banana),
      reason: 'check the functionality of the system. '
          'Closing other containers should not affect our db',
    );
  });
  // Todo: check Provider.autodispose and overrideWithValue
  // test('Watcher+Riverpod', () async {
  //   final container = ProviderContainer();
  //
  //   final DbUser db = container.read(dbProvider);
  //
  //   await db.init();
  //
  //   final container2 = ProviderContainer(overrides: [
  //     dbProvider.overrideWithValue(db),
  //   ]);
  //
  //   print("Получено значение: ${container1.read(bananaProvider)}");
  //   print("Получено значение: ${container2.read(bananaTooProvider)}");
  //
  //   expect(FruitCard.banana.defaultValue, container1.read(bananaProvider));
  //   expect(FruitCard.banana.defaultValue, container2.read(bananaTooProvider));
  //
  //   await db.set<int>(FruitCard.banana, 5);
  //
  //   print('1-banana pr: ${container1.read(bananaProvider)}');
  //   print("1-bananaToo pr: ${container2.read(bananaTooProvider)}");
  //
  //   container1.dispose();
  //
  //   print("2-bananaToo pr: ${container2.read(bananaTooProvider)}");
  //
  //   await db.set<int>(FruitCard.banana, 6);
  //   print("3-bananaToo pr: ${container1.read(bananaProvider)}");
  // });
}
