import 'package:bloc/bloc.dart';
import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:meta/meta.dart';

import 'app_cardoteka.dart';

// I created an instance of Cardoteka and cards earlier, and here I'm just
// showing you their types and uses
final AppCardoteka cardoteka = appCardoteka;
const AppSettings<ThemeMode> card =
    AppSettings.themeMode; // with defaultValue=ThemeMode.system

class CubitThemeMode extends Cubit<ThemeMode> with DetacherCubitV2 {
  CubitThemeMode(super.initialState);

  void onNewTheme(ThemeMode value) => emit(value);
}

Future<void> main() async {
  await Cardoteka.init();

  final themeMode = cardoteka.get(card);

  final cubit = CubitThemeMode(themeMode);
  cardoteka.attach(
    card,
    onChange: cubit.onNewTheme,
    onRemove: () => cubit.onNewTheme(card.defaultValue),
    detacher: cubit.onDetach, // a line that allows you to fix memory leaks
  );

  await cardoteka.set<ThemeMode>(card, ThemeMode.light);
  // What happened?
  // 1. Get current `themeMode` from storage by card
  // 2. Create `CubitThemeMode` with actual `themeMode`
  // 3. Attach a watcher to this card, which will notify the `CubitImpl` about new values
  // 4. We save the new value to cardoteka, and after triggering watcher...
  // 4. What does the `onNewTheme` method call...
  // 5. And `CubitThemeMode` emit new state `ThemeMode.light`.
}

/// Below are two versions of the [Detachability] functionality that you can use.
/// Just copy one of them into your code and use it everywhere for any cubit.

// fixdep(1.12.2023): [Allow mixins in "extends" clauses · Issue #1942 · dart-lang/language](https://github.com/dart-lang/language/issues/1942)
// ```dart
// mixin CubitDetacher<T> on Cubit<T> extends Detachability {}
// // and then...
// class MyCubit extends Cubit<Object> with CubitDetacher {}
// ```
/// First implementation of [Detachability] from `cardoteka` package. Copy.
mixin DetacherCubitV1<T> on Cubit<T> implements Detachability {
  @override
  @mustCallSuper
  Future<void> close() async {
    detach();

    return super.close();
  }
}

class CubitThemeModeV1 extends Cubit<ThemeMode>
    with DetacherCubitV1, Detachability {
  CubitThemeModeV1() : super(card.defaultValue) {
    cardoteka.attach(
      card,
      onChange: (ThemeMode value) => emit(value),
      fireImmediately: true,
      onRemove: () => emit(card.defaultValue),
      detacher: onDetach,
    );
  }

  void setThemeMode(ThemeMode value) =>
      cardoteka.set(AppSettings.themeMode, value);
}

/// Second implementation of [Detachability] from `cardoteka` package. Copy.
mixin DetacherCubitV2<T> on Cubit<T> implements Detachability {
  final _detachability = Detachability();

  @override
  void onDetach(void Function() cb) => _detachability.onDetach(cb);

  @override
  void detach() => _detachability.detach();

  @override
  @mustCallSuper
  Future<void> close() async {
    detach();
    return super.close();
  }
}

class CubitThemeModeV2 extends Cubit<ThemeMode> with DetacherCubitV2 {
  CubitThemeModeV2() : super(card.defaultValue) {
    cardoteka.attach(
      card,
      onChange: (ThemeMode value) => emit(value),
      onRemove: () => emit(card.defaultValue),
      fireImmediately: true,
      detacher: onDetach,
    );
  }

  void setThemeMode(ThemeMode value) =>
      cardoteka.set(AppSettings.themeMode, value);
}
