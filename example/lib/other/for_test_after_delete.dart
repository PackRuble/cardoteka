// ignore_for_file: unreachable_from_main

import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart' show Color, ThemeMode;

enum UserPage { home, search, favorites, settings }

enum SettingsCards<T> implements Card<T> {
  homePage<UserPage>(DataType.string, UserPage.search),
  userColor<Color>(DataType.int, Color.fromARGB(255, 79, 199, 112)),
  lastLoginTime<DateTime?>(DataType.int, null, 'last_login_time_key'),
  themeDefault<String>(DataType.string, 'mustard'),
  themeMode<ThemeMode>(DataType.int, ThemeMode.dark),
  startPage<int>(DataType.int, 104),
  sessionDuration<Duration>(DataType.int, Duration(days: 1)),
  ;

  const SettingsCards(this.type, this.defaultValue, [this.customKey]);

  @override
  final DataType type;

  @override
  final T defaultValue;

  final String? customKey;

  @override
  String get key => customKey ?? name;

  static Map<SettingsCards, Converter> get converters => const {
        themeMode: EnumAsIntConverter(UserPage.values),
        lastLoginTime: Converters.dateTimeAsInt,
        homePage: EnumAsStringConverter(UserPage.values),
        sessionDuration: Converters.durationAsInt,
      };
}

class SettingsCardoteka extends Cardoteka {
  SettingsCardoteka({required super.config});
}

main() async {
  await Cardoteka.init();

  final cardoteka = SettingsCardoteka(
    config: CardotekaConfig(
      name: 'SettingsCardoteka',
      cards: SettingsCards.values,
      converters: SettingsCards.converters,
    ),
  );

  ThemeMode themeMode = cardoteka.get(SettingsCards.themeMode); // will return default value
  await cardoteka.set<ThemeMode>(SettingsCards.themeMode, ThemeMode.light);
  themeMode = cardoteka.get(SettingsCards.themeMode); // ThemeMode.light

  DateTime? lastLoginTime = cardoteka.getOrNull(SettingsCards.lastLoginTime); // null
  await cardoteka.setOrNull<DateTime>(SettingsCards.lastLoginTime, DateTime.now());
  lastLoginTime = cardoteka.getOrNull(SettingsCards.lastLoginTime); // saved time

  cardoteka.getStoredCards(); // {SettingsCards.themeMode, SettingsCards.lastLoginTime}

  await cardoteka.remove(SettingsCards.userColor); // nothing will happen
  await cardoteka.remove(SettingsCards.lastLoginTime); // lastLoginTime removed from storage
  cardoteka.getStoredEntries(); // {SettingsCards.themeMode: ThemeMode.light}

  await cardoteka.removeAll();
  cardoteka.getStoredCards(); // {}
}
