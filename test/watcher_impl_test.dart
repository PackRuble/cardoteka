import 'package:cardoteka/cardoteka.dart';
import 'package:cardoteka/src/core.dart' show CardotekaUtilsForTest;
import 'package:flutter_test/flutter_test.dart';

enum FishCard<T> implements Card<T> {
  perch<int>(DataType.int, 2023),
  perchGhost<int?>(DataType.int, 2024),
  perchGhostNull<int?>(DataType.int, null),
  ;

  const FishCard(this.type, this.defaultValue);

  @override
  final DataType type;

  @override
  final T defaultValue;

  @override
  String get key => name;
}

class CardotekaTest extends Cardoteka
    with WatcherImpl, WatcherImplDebug, CardotekaUtilsForTest, AccessToSP {
  CardotekaTest({required super.config});
}

typedef AsyncCallback = Future<void> Function();

void main() {
  late CardotekaTest cardoteka;
  setUp(() async {
    cardoteka = CardotekaTest(
      config: const CardConfig(name: '', cards: FishCard.values),
    );
    cardoteka.setMockInitialValues({});
    await Cardoteka.init();
  });

  tearDown(() {
    cardoteka.deInit();
  });

  // attachedCallback;
  // setUpAll(() {});

  group('$WatcherImpl.attach -> What does attach return when SP is empty?', () {
    const reason = 'Should always return to default';
    test('If non-nullable card', () {
      const card = FishCard.perch;
      final value = cardoteka.attach(card, (_) {}, detacher: null);

      expect(value, card.defaultValue, reason: reason);
    });

    test('If nullable card with non-null default value', () {
      const card = FishCard.perchGhost;
      final value = cardoteka.attach(card, (_) {}, detacher: null);

      expect(value, card.defaultValue, reason: reason);
    });

    test('If nullable card with null default value', () {
      const card = FishCard.perchGhostNull;
      final value = cardoteka.attach(card, (_) {}, detacher: null);

      expect(value, card.defaultValue, reason: reason);
    });
  });

  group('$WatcherImpl.attach -> Correct operation of callback', () {
    const reason =
        'The callback should return a new value as soon as it changes'
        ' in the store';

    test('Checking operations that call a callback', () async {
      const card = FishCard.perch;
      final doubledValue = card.defaultValue * 2;
      final tripledValue = card.defaultValue * 3;
      int counter = 0;
      final actionForResultInCallback = <AsyncCallback, int>{
        () async => cardoteka.set<int>(card, doubledValue): doubledValue,
        () async => cardoteka.remove(card): card.defaultValue,
        () async => cardoteka.setOrNull<int>(card, tripledValue): tripledValue,
        () async => cardoteka.removeAll(): card.defaultValue,
      }.entries.toList();
      cardoteka.attach<int>(
        card,
        (cbValue) async {
          expect(
            cbValue,
            actionForResultInCallback[counter++].value,
            reason: reason,
          );
        },
        detacher: null,
      );

      await Future.wait(actionForResultInCallback.map((e) => e.key()));

      expect(
        actionForResultInCallback,
        hasLength(counter),
        reason: 'All operations must trigger the callback',
      );
    });
  });
}
