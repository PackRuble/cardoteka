import 'package:cardoteka/cardoteka.dart';
import 'package:riverpod/riverpod.dart';

import 'app_cardoteka.dart';

// I created an instance of Cardoteka and cards earlier, and here I'm just
// showing you their types and uses
final cardotekaProvider = Provider((_) => appCardoteka);
const AppSettings<HomePageState> card =
    AppSettings.homePageState; // with defaultValue=HomePageState.unknown

final homePageStateProvider = Provider<HomePageState>(
  (ref) => ref.watch(cardotekaProvider).attach(
        card,
        onChange: (value) => ref.state = value,
        onRemove: () => ref.state = HomePageState.unknown,
        detacher: ref.onDispose,
      ),
);

Future<void> main() async {
  await Cardoteka.init();
  final container = ProviderContainer();
  final cardoteka = container.read(cardotekaProvider);

  HomePageState homePageState = container.read(homePageStateProvider);
  print('$homePageState'); // card.defaultValue-> HomePageState.unknown

  await cardoteka.set(card, HomePageState.open);
  homePageState = container.read(homePageStateProvider);
  print('$homePageState');
  // 1. a value was saved to storage
  // 2. the callback we passed to `attach` is called.
  // 3. print-> HomePageState.open

  await cardoteka.remove(card);
  homePageState = container.read(homePageStateProvider);
  print('$homePageState');
  // 1. a value was removed from storage
  // 2. the function we passed to `onRemove` is called.
  // 3. print-> HomePageState.unknown
}
