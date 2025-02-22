## [2.0.0] - 10-02-2025

- upd: minimum supported SDK version to Flutter 3.24.0/Dart 3.5.0
- 🛡️fix: [Implement security advisories CWE-502](https://github.com/PackRuble/cardoteka/issues/29)
- new: now you can directly create an instance of the `Cardoteka` ([#15](https://github.com/PackRuble/cardoteka/issues/15))
- new: `CardotekaAsync` for asynchronous data retrieval (works without cache) ([#24](https://github.com/PackRuble/cardoteka/issues/24))
- 🧨upd: all declarations of own classes from `Cardoteka` and `CardotekaAsync` must now necessarily be declared as `final` or `base` or `sealed`
- 🧨upd: `AccessToSP` has been deleted. Use `import package:cardoteka/access_to_sp.dart`.
- 🧨upd: changes in `Watcher.attach`: `onRemove` parameter is now required and callback is now a named `onChange` parameter ([#14](https://github.com/PackRuble/cardoteka/issues/14), [#37](https://github.com/PackRuble/cardoteka/issues/37))
- add: `Detachability` and `DetacherChangeNotifier`for easy dispose of linked resources in classes with business logic ([#10](https://github.com/PackRuble/cardoteka/issues/10), [#9](https://github.com/PackRuble/cardoteka/issues/9))
- add: `CRUD.readAsync` method for use with `CardotekaAsync`
- add: `notifyAll` method for `Watcher` ([#17](https://github.com/PackRuble/cardoteka/issues/17))
- upd: `Converters.colorAsInt` is temporarily deprecated. See more details in ([#31](https://github.com/PackRuble/cardoteka/issues/31))
- add: `CardotekaMigrator.migrate` method for data migration ([#33](https://github.com/PackRuble/cardoteka/issues/33))
- upd: all examples in `example` folder have been updated
- upd: some internal methods have been hidden from the IDE prompts to make package easier to use
- doc: "Notifier (riverpod)", "Analogy in `SharedPreferencesWithCache` and `SharedPreferencesAsync`", "Migration", "Sync or Async storage", "Detachability" sections were added to readme

You can see all closed issues in [Milestone v2.0.0](https://github.com/PackRuble/cardoteka/milestone/2?closed=1).

Also, read `readme.md` section on data migration [Cardoteka from v1 to v2](https://github.com/PackRuble/cardoteka?tab=readme-ov-file#cardoteka-from-v1-to-v2).

## [1.1.0] - 02-10-2024

- upd: minimum supported SDK version to Flutter 3.13.0/Dart 3.1.0
- fix: incorrect assert message about initialization, close [#12](https://github.com/PackRuble/cardoteka/issues/12)
- 🧨upd: if you used `CollectionConverter` and its inheritors, you are now only allowed to use them by using `extends` and adding `final` modifier to your class (or `base`|`sealed`)
- 🧨upd: `Cardoteka.setPrefix` now static. Add `allowList` parameter. The `prefix` now named parameter.
- 🧨add: use `CardotekaUtilsForTest.setMockInitialCards` method instead of `CardotekaUtilsForTest.setMockInitialValues`, which is now responsible for the original `SharedPreferences.setMockInitialValues` method. Close [#16](https://github.com/PackRuble/cardoteka/issues/16)
- doc: "Obfuscate", "Materials", "Apps", "Saving null values" sections were added to readme

You can see all closed issues in [Milestone v1.1.0](https://github.com/PackRuble/cardoteka/milestone/1?closed=1)

## [1.0.1] - 22-12-2023

- fix: remove invalid example from `example`
- upd: description

## [1.0.0] - 22-12-2023

first public release 🎊

- fully documented code
- with examples of use in the `example/lib` folder
- code is covered by tests (with a coverage percentage >80%)
- prepared readme.md with architecture overview

## [0.0.1] - 04-11-2022

- 🍕 How about some pizza, pub.dev?
