import 'package:cardoteka/cardoteka.dart';
import 'package:riverpod/riverpod.dart';

// ignore_for_file: definitely_unassigned_late_local_variable
// to☝️do: create an instance of cardoteka and pass configuration with cards
late CardotekaImpl cardoteka;
late Card<RoomDoorState> doorStateCard; // defaultValue = RoomDoorState.ajar

class CardotekaImpl = Cardoteka with WatcherImpl;

enum RoomDoorState { open, closed, ajar, unknown }

final cardotekaProvider = Provider<CardotekaImpl>((ref) {
  return cardoteka;
});

final doorStateProvider = Provider<RoomDoorState>((ref) {
  return ref.watch(cardotekaProvider).attach(
        doorStateCard,
        (value) => ref.state = value,
        onRemove: () => ref.state = RoomDoorState.unknown,
        detacher: ref.onDispose,
      );
});

Future<void> main() async {
  await Cardoteka.init();
  final container = ProviderContainer();

  RoomDoorState doorState = container.read(doorStateProvider);
  print('$doorState'); // lastOrderCard.defaultValue-> RoomDoorState.ajar

  await container.read(cardotekaProvider).set(doorStateCard, RoomDoorState.open);
  doorState = container.read(doorStateProvider);
  print('$doorState');
  // 1. a value was saved to storage
  // 2. the callback we passed to `attach` is called.
  // 3. print-> RoomDoorState.open

  await container.read(cardotekaProvider).remove(doorStateCard);
  doorState = container.read(doorStateProvider);
  print('$doorState');
  // 1. a value was removed from storage
  // 2. the function we passed to `onRemove` is called.
  // 3. print-> RoomDoorState.unknown
}
