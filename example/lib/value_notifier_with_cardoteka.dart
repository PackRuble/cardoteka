import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart';

import 'app_cardoteka.dart';

// I created an instance of Cardoteka and cards earlier, and here I'm just
// showing you their types and uses
final AppCardoteka cardoteka = appCardoteka;
const AppSettings<bool> card = AppSettings.isPremium; // with defaultValue=false

/// An example of using [Cardoteka] with the [WatcherImpl] and
/// [DetacherChangeNotifier] mixins for the [ValueNotifier] state class.
class PremiumNotifier extends ValueNotifier<bool> with DetacherChangeNotifier {
  PremiumNotifier(super.isPremium);

  Future<void> checkPremium() async {
    final bool result = await Future.delayed(
      // simulate server request delay
      const Duration(milliseconds: 100),
      () => true,
    );

    await cardoteka.set(card, result);
  }
}

Future<void> main() async {
  await Cardoteka.init();

  // We get a previously saved value from storage.
  // If isn't present, `card.defaultValue` will be returned.
  final isPremium = cardoteka.get(card);
  final premiumNR = PremiumNotifier(isPremium);
  print('1️⃣State is premium?: value=${premiumNR.value}');

  cardoteka.attach(
    card,
    (value) => premiumNR.value = value,
    detacher: premiumNR.onDetach, // a line that allows you to fix memory leaks
  );

  await premiumNR.checkPremium();
  print('2️⃣State is premium?: value=${premiumNR.value}');

  await cardoteka.set(card, false);
  print('3️⃣State is premium?: value=${premiumNR.value}');

  premiumNR.dispose();

  // What happened?
  // 1. Get current value from storage by card
  // 2. console-> 1️⃣State is premium?: value=false
  // 3. Attach a watcher to this card, which will notify the notifier about new values
  // 4. Check premium on the server by calling `PremiumNotifier.checkPremium` method
  // 5. console-> 2️⃣State is premium?: value=true
  // 6. We save the new value to cardoteka, and after triggering watcher..:
  // 7. console-> 3️⃣State is premium?: value=false
  //
  // That is, roughly speaking, we can have very many notifiers with wiretapping attached
  // that will automatically update the state after the values in the storage change.
}
