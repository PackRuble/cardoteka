import 'package:cardoteka/cardoteka.dart';
import 'package:cardoteka_sp/cardoteka_sp.dart';
import 'package:flutter/material.dart' show ThemeMode;

enum AppLocale { ru, de, en, pl, uk }

enum HomePageState { open, closed, minimized, unknown }

enum AppSettings<T extends Object?> implements Card<T> {
  themeMode(DataType.string, ThemeMode.system),
  recentActivityList(DataType.stringList, <String>[]),
  isPremium(DataType.bool, false),
  homePageState(DataType.string, HomePageState.unknown),
  appLocale(DataType.string, AppLocale.en),
  feedCatAtAppointedTime<DateTime?>(DataType.int, null),
  ;

  const AppSettings(this.type, this.defaultValue);

  @override
  final DataType type;

  @override
  final T defaultValue;

  @override
  String get key => name;

  static const converters = <Card, Converter>{
    themeMode: EnumAsStringConverter(ThemeMode.values),
    homePageState: EnumAsStringConverter(HomePageState.values),
    appLocale: EnumAsStringConverter(AppLocale.values),
    feedCatAtAppointedTime: Converters.dateTimeAsInt,
  };
}

final class AppCardoteka = Cardoteka with WatcherImpl;
final appCardoteka = AppCardoteka(
  storage: CardotekaSpSync(const StorageConfig()),
  config: const CardotekaConfig(
    prefix: 'app_settings',
    cards: AppSettings.values,
    converters: AppSettings.converters,
  ),
);
