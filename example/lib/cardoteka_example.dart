import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart' hide Card;

enum AppLocale { ru, de, en, pl, uk }

enum SettingsCards<T extends Object?> implements Card<T> {
  userColor(DataType.int, Color(0x00FF4BFF)),
  themeMode(DataType.string, ThemeMode.light),
  recentActivityList(DataType.stringList, <String>[]),
  isPremium(DataType.bool, false),
  appLocale(DataType.string, AppLocale.en),
  feedCatAtAppointedTime<DateTime?>(DataType.int, null),
  backgroundOpacity(DataType.double, 0.8),
  ;

  const SettingsCards(this.type, this.defaultValue);

  @override
  final DataType type;

  @override
  final T defaultValue;

  @override
  String get key => name;

  static const converters = <Card, Converter>{
    userColor: Converters.colorAsInt,
    themeMode: EnumAsStringConverter(ThemeMode.values),
    appLocale: EnumAsStringConverter(AppLocale.values),
    feedCatAtAppointedTime: Converters.dateTimeAsInt,
  };
}

final class SettingsCardoteka extends Cardoteka with WatcherImpl {
  SettingsCardoteka({required super.config});
}

final class SettingsAsync extends CardotekaAsync {
  SettingsAsync({required super.config});
}

void main() async {
  // if binding occurs before runApp is called
  WidgetsFlutterBinding.ensureInitialized();

  await Cardoteka.init();

  const cardotekaConfig = CardotekaConfig(
    name: 'settings',
    cards: SettingsCards.values,
    converters: SettingsCards.converters,
  );

  // Create an instance based on your cardoteka class
  final cardoteka = SettingsCardoteka(config: cardotekaConfig);

  // or create an instance using base class
  // ```dart
  // final cardoteka = Cardoteka(config: cardotekaConfig);
  // ```
  // or create an instance based on your cardoteka class to access asynchronous operations
  // ```dart
  // final cardotekaAsync = SettingsAsync(
  //   config: const CardotekaConfig(
  //     name: 'settings',
  //     cards: [SettingsCards.recentActivityList],
  //   ),
  // );
  // ```

  final log = StringBuffer('All notifications for SettingsCards.themeMode:\n');
  cardoteka.attach(
    SettingsCards.themeMode,
    (value) => log.writeln('-> $value'),
    onRemove: () => log.writeln('-> has been removed from storage'),
    detacher: (onDetach) {
      // pass onDetach to whoever is responsible for the lifetime of the object
    },
  );

  ThemeMode themeMode = cardoteka.get(SettingsCards.themeMode);
  print(themeMode); // will return default value -> ThemeMode.light

  await cardoteka.set(SettingsCards.themeMode, ThemeMode.dark); // first log
  themeMode = cardoteka.get(SettingsCards.themeMode);
  print(themeMode); // ThemeMode.dark

  // you can use generic type to prevent possible errors when passing arguments
  // of different types
  await cardoteka.set<bool>(SettingsCards.isPremium, true);
  await cardoteka.set<Color>(SettingsCards.userColor, Colors.deepOrange);

  await cardoteka.remove(SettingsCards.themeMode); // second log
  Map<Card<Object?>, Object> storedEntries = cardoteka.getStoredEntries();
  print(storedEntries);
  // {
  //   SettingsCards.userColor: Color(0xffff5722),
  //   SettingsCards.isPremium: true
  // }

  await cardoteka.removeAll(); // third log
  storedEntries = cardoteka.getStoredEntries();
  print(storedEntries); // {}

  print(log); // All notifications for SettingsCards.themeMode:
  // -> ThemeMode.dark
  // -> has been removed from storage
  // -> has been removed from storage
}
