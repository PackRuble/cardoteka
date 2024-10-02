## [1.1.0] - 02-10-2024

- upd: minimum supported SDK version to Flutter 3.13/Dart 3.1.0
- fix: incorrect assert message about initialization, close #12
- 🧨upd: if you used `CollectionConverter` and its inheritors, you are now only allowed to use them by using `extends` and adding `final` modifier to your class (or `base`|`sealed`)
- 🧨upd: `Cardoteka.setPrefix` now static. Add `allowList` parameter. The `prefix` now named parameter.
- 🧨add: use `CardotekaUtilsForTest.setMockInitialCards` method instead of `CardotekaUtilsForTest.setMockInitialValues`, which is now responsible for the original `SharedPreferences.setMockInitialValues` method. Close #16
- doc: `Obfuscate`, `Materials`, `Apps`, `Saving null values` sections were added to readme

You can see all closed issues in [Milestone v1.1.0](https://github.com/PackRuble/cardoteka/milestone/1)

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
