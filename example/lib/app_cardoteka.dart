import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart' show ThemeMode;

enum AppSettings<T> implements Card<T> {
  themeMode(DataType.string, ThemeMode.system),
  recentActivityList(DataType.stringList, <String>[]),
  isPremium(DataType.bool, false),
  ;

  const AppSettings(this.type, this.defaultValue);

  @override
  final DataType type;

  @override
  final T defaultValue;

  @override
  String get key => name;

  static const converters = {
    themeMode: EnumAsStringConverter(ThemeMode.values),
  };
}

final class AppCardoteka = Cardoteka with WatcherImpl;
final appCardoteka = AppCardoteka(
  config: const CardotekaConfig(
    name: 'app_settings',
    cards: AppSettings.values,
    converters: AppSettings.converters,
  ),
);
