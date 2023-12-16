import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart' hide Card;

enum SettingsCards<T extends Object> implements Card<T> {
  userColor(DataType.int, Color(0x00FF4BFF)),
  themeMode<ThemeMode>(DataType.string, ThemeMode.light),
  isPremium(DataType.bool, false),
  ;

  const SettingsCards(this.type, this.defaultValue);

  @override
  final DataType type;

  @override
  final T defaultValue;

  @override
  String get key => name;

  static Map<SettingsCards, Converter> get converters => const {
        themeMode: EnumAsStringConverter(ThemeMode.values),
        userColor: Converters.colorAsInt,
      };
}

class SettingsCardoteka extends Cardoteka with WatcherImpl {
  SettingsCardoteka({required super.config});
}

void main() async {
  await Cardoteka.init();
  final cardoteka = SettingsCardoteka(
    config: CardotekaConfig(
      name: 'settings',
      cards: SettingsCards.values,
      converters: SettingsCards.converters,
    ),
  );

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
