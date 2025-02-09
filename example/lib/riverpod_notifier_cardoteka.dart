import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_cardoteka.dart';

// I created an instance of Cardoteka and cards earlier, and here I'm just
// showing you their types and uses
final cardotekaProvider = Provider((_) => appCardoteka);
const AppSettings<AppLocale> card =
    AppSettings.appLocale; // with defaultValue=AppLocale.en

class LocaleNotifier extends Notifier<AppLocale> {
  static final i =
      NotifierProvider<LocaleNotifier, AppLocale>(LocaleNotifier.new);

  late AppCardoteka _storage;

  @override
  AppLocale build() {
    _storage = ref.watch(cardotekaProvider);

    return _storage.attach(
      card,
      onChange: (value) => state = value,
      detacher: ref.onDispose,
      onRemove: () => state = card.defaultValue,
    );
  }

  Future<void> changeLocale(AppLocale locale) async =>
      await _storage.set(card, locale);

  Future<void> resetLocale() async => await _storage.remove(card);
}

Future<void> main() async {
  await Cardoteka.init();
  runApp(const ProviderScope(child: LocaleSelectorApp()));
}

class LocaleSelectorApp extends ConsumerWidget {
  const LocaleSelectorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localePR = LocaleNotifier.i;
    final localeNR = ref.watch(localePR.notifier);
    final locale = ref.watch(localePR);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Column(
          children: [
            const Spacer(),
            Center(
              child: Text(
                locale.localizedName,
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            const Spacer(),
            DropdownMenu(
              initialSelection: locale,
              dropdownMenuEntries: [
                for (final locale in AppLocale.values)
                  DropdownMenuEntry(
                    label: '$locale',
                    value: locale,
                  ),
              ],
              onSelected: (value) {
                if (value == null) return;
                localeNR.changeLocale(value);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextButton(
                onPressed: localeNR.resetLocale,
                child: const Text('Reset locale'),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

extension AppLocaleX on AppLocale {
  String get localizedName => switch (this) {
        AppLocale.ru => 'Русский',
        AppLocale.en => 'English',
        AppLocale.uk => 'Українська',
        AppLocale.pl => 'Polski',
        AppLocale.de => 'Deutsch',
      };
}
