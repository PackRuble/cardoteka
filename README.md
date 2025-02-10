<a href="https://github.com/PackRuble/cardoteka/"><img src="https://github.com/PackRuble/cardoteka/blob/dev/res/cardoteka_banner.png?raw=true"/></a>

## Cardoteka

[![telegram_badge]][telegram_link]
[![pub_badge]][pub_link]
[![pub_likes]][pub_link]
[![codecov_badge]][codecov_link]
[![license_badge]][license_link]
[![code_size_badge]][repo_link]
[![repo_star_badge]][repo_link]

⭐️ The best type-safe wrapper over SharedPreferences.

> Put a ![][pub_like_icon] on [Pub][pub_link] and favorite ⭐ on [Github][repo_link] to keep up with changes and not miss new releases!

## Advantages

Why should I prefer to use [`cardoteka`](https://pub.dev/packages/cardoteka) instead of the original [`shared_preferences`](https://pub.dev/packages/shared_preferences)? The reasons are as follows:
- 🎈 Easy data retrieval synchronously (based on pre-caching) or asynchronously using `Cardoteka` and `CardotekaAsync`.
- 🧭 Your keys and default values are stored in a systematic and organized manner. You don't have to think about where to stick them.
- 🎼 Use `get` or `set` instead of a heap of `getBool`, `setDouble`, `getInt`, `getStringList`, `setString`... Think about the business logic of entities, not how to store or retrieve them.
- 📞 Update state as soon as new data arrives in storage. No to code duplication - use `Watcher`.
- 🧯 Have to frequently check the value for null before saving? Use the `getOrNull` and `setOrNull` methods and don't worry about anything!
- 🚪 Do you still need access to dynamic methods or an SP instance from the original library? Just add the `import package:cardoteka/access_to_sp.dart`.

## Table of contents

<!-- TOC -->
  * [Cardoteka](#cardoteka)
  * [Advantages](#advantages)
  * [Table of contents](#table-of-contents)
  * [How to use?](#how-to-use)
  * [Materials](#materials)
  * [Apps](#apps)
  * [Analogy in `SharedPreferencesWithCache` and `SharedPreferencesAsync`](#analogy-in-sharedpreferenceswithcache-and-sharedpreferencesasync)
  * [Sync or Async storage](#sync-or-async-storage)
  * [Saving null values](#saving-null-values)
  * [Structure](#structure)
    * [`Cardoteka` and `CardotekaAsync`](#cardoteka-and-cardotekaasync)
    * [`Card`](#card)
    * [`Converter`](#converter)
    * [`Watcher`](#watcher)
    * [`Detachability`](#detachability)
  * [Use with](#use-with)
    * [`ChangeNotifier`](#changenotifier)
    * [`ValueNotifier`](#valuenotifier)
    * [`Cubit` (bloc)](#cubit-bloc)
    * [`Provider` (riverpod)](#provider-riverpod)
    * [`Notifier` (riverpod)](#notifier-riverpod)
  * [Migration](#migration)
    * [Cardoteka from v1 to v2](#cardoteka-from-v1-to-v2)
  * [Obfuscate](#obfuscate)
  * [Coverage](#coverage)
  * [Author](#author)
<!-- TOC -->

## How to use?

1. Define your cards: specify the type to be stored and the default value (for default values with nullable support, be sure to specify generic type). Additionally, specify converters if the value type cannot be represented in the existing `DataType` enumeration:

```dart
import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart' show ThemeMode;

enum AppSettings<T extends Object?> implements Card<T> {
  themeMode(DataType.string, ThemeMode.system),
  recentActivityList(DataType.stringList, <String>[]),
  isPremium(DataType.bool, false),
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
    feedCatAtAppointedTime: Converters.dateTimeAsInt,
  };
}
```

2. Select the cardoteka class required in your case - `Cardoteka` (based on pre-caching) or `CardotekaAsync` for asynchronous data retrieval (see [Sync or Async storage](https://github.com/PackRuble/cardoteka?tab=readme-ov-file#sync-or-async-storage)). For the `Cardoteka` class, perform initialization via `Cardoteka.init` and take advantage of all the features of your cardoteka: save, read, delete, listen to your saved data using typed cards:

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Cardoteka.init();
  final cardoteka = Cardoteka(
    config: const CardotekaConfig(
      name: 'settings',
      cards: SettingsCards.values,
      converters: SettingsCards.converters,
    ),
  );

  ThemeMode themeMode = cardoteka.get(SettingsCards.themeMode);
  print(themeMode); // will return default value -> ThemeMode.light

  await cardoteka.set(SettingsCards.themeMode, ThemeMode.dark);
  themeMode = cardoteka.get(SettingsCards.themeMode);
  print(themeMode); // ThemeMode.dark

  // you can use generic type to prevent possible errors when passing arguments
  // of different types
  await cardoteka.set<bool>(SettingsCards.isPremium, true);
  await cardoteka.set<Color>(SettingsCards.userColor, Colors.deepOrange);

  await cardoteka.remove(SettingsCards.themeMode);
  Map<Card<Object?>, Object> storedEntries = cardoteka.getStoredEntries();
  print(storedEntries);
  // {
  //   SettingsCards.userColor: Color(0xffff5722),
  //   SettingsCards.isPremium: true
  // }

  await cardoteka.removeAll();
  storedEntries = cardoteka.getStoredEntries();
  print(storedEntries); // {}
}
```

**Don't worry!** If you do something wrong, you will receive a detailed correction message in the console.

## Materials

List of resources to learn more about the capabilities of this library:
- [Stop using dynamic key-value storage! Use Cardoteka for typed access to Shared Preferences | by Ruble | Medium](https://medium.com/@pack.ruble/stop-using-dynamic-key-value-storage-use-cardoteka-for-typed-access-to-shared-preferences-567c9f799d7d)
- [Я сделал Cardoteka и вот как её использовать [кто любит черпать] / Хабр](https://habr.com/ru/articles/783712/)
- [Cardoteka — техническая начинка и аналитика решений типобезопасной SP [кто любит вдаваться] / Хабр](https://habr.com/ru/articles/801089/)
- [Приложение викторины: внедрение Cardoteka и основные паттерны проектирования с Riverpod / Хабр](https://habr.com/ru/articles/799437/)

## Apps

Applications that use this library:
- [Weather Today](https://github.com/PackRuble/weather_today) - weather app
- [Quiz Prize](https://github.com/PackRuble/quiz_prize_app) - quiz game deployed on [web](https://packruble.github.io/quiz_prize_app)
- [PackRuble/reactive_domain_playground](https://github.com/PackRuble/reactive_domain_playground) - sandbox for practicing skills in a reactive Domain layer

## Analogy in `SharedPreferencesWithCache` and `SharedPreferencesAsync`

| `SharedPreferencesWithCache` or `SharedPreferencesAsync` | Method \ return signature | `Cardoteka`         | `CardotekaAsync`            |
|----------------------------------------------------------|---------------------------|---------------------|-----------------------------|
| `get*`                                                   | `get`                     | `V`                 | `Future<V>`                 |
| —                                                        | `getOrNull`               | `V?`                | `Future<V?>`                |
| `set*`                                                   | `set`                     | `Future<bool>`      | `Future<bool>`              |
| —                                                        | `setOrNull`               | `Future<bool>`      | `Future<bool>`              |
| `remove`                                                 | `remove`                  | `Future<bool>`      | `Future<bool>`              |
| `clear`                                                  | `removeAll`               | `Future<bool>`      | `Future<bool>`              |
| `containsKey`                                            | `containsCard`            | `bool`              | `Future<bool>`              |
| `keys` and `getKeys`                                     | `getStoredCards`          | `Set<Card>`         | `Future<Set<Card>>`         |
| —                                                        | `getStoredEntries`        | `Map<Card, Object>` | `Future<Map<Card, Object>>` |
| `reloadCache`                                            | `reloadCache`             | `Future<void>`      | —                           |


## Sync or Async storage

The biggest difference between `Cardoteka` and `CardotekaAsync` is where the data is stored when the application is running. In the synchronous case, all data for all cards are loaded once into the device RAM after calling `Cardoteka.init`. This is why you can use methods such as `get`, `getOrNull`, `containsCard`, `getStoredCards`, `getStoredEntries` synchronously. It is also important to understand that if another service on the platform changes your data, you need to call `Cardoteka.reloadCache` to update it before retrieving it via a `Cardoteka` instance.

Things are different for `CardotekaAsync` because data is asynchronously requested from disk when any method is called. This is why initialization is not required in advance. And because of this, you get the most up-to-date data for any query.

But which one to use when? It's simple: 
- if your data is updated by another service (and you can't track it)
- OR your data is too heavy (lists with instances of classes with a large number of fields are serialized)
- OR synchronous reading is not that important to you
 
then feel free to use `CardotekaAsync`. Otherwise, use `Cardoteka`.

## Saving null values

If your card can contain a null value, then use the `getOrNull` and `setOrNull` methods. It works like this:
- `getOrNull` - if pair is absent in storage, we will get `null`
- `setOrNull` - if we save `null`, the pair will be deleted from storage

Below is a table showing the compatibility of methods with cards:

|   method    | Card<Object\> | Card<Object?> |
|:-----------:|:-------------:|:-------------:|
|    `get`    |       ✅       |       ❌       |
|    `set`    |       ✅       |       ✅       |
| `getOrNull` |       ✅       |       ✅       |
| `setOrNull` |       ✅       |       ✅       |

By and large, most often you will use `get`/`set`, and when you need to simulate working with null, or when there is no pair, you want to get `null` (and not the default value) - we use `getOrNull`/ `setOrNull`.

## Structure

The structure of the library is very simple! Below are the main classes you will have to work with.

| Basic elements of Cardoteka      | Purpose                                              |
|----------------------------------|------------------------------------------------------|
| `Cardoteka` and `CardotekaAsync` | Classes for working with storage                     |
| `CardotekaConfig`                | Configuration file for a `CardotekaCore` instance    |
| `Card`                           | Key to the storage to interact with it               |
| `Converter` & `Converters`       | Transforming objects to interact with storage        |
| `Watcher`                        | Allows you to listen for changing values in storage  |
| `Detachability`                  | Allows you to remove linked resources when listening |

### `Cardoteka` and `CardotekaAsync`

Main class for implementing your own storage instance. Contains all the basic methods for working with SharedPreferences in a typed style. Serves as a wrapper over SP. Use as many implementations (and instances) as needed, passing a unique name in the parameters. Use mixins to extend functionality. Use `Cardoteka` for synchronous data reading (pre-caching via `init`), and `CardotekaAsync` for asynchronous data access (without cache).

| Mixin for `CardotekaCore` | Purpose                                     |
|---------------------------|---------------------------------------------|
| `Watcher`<-`WatcherImpl`  | To implement wiretapping based on callbacks |
| `CRUD`                    | To simulate crud operations                 |

Use `import package:cardoteka/access_to_sp.dart` to access classes of the original `shared_preferences`.

### `Card`

Every instance of Cardoteka needs cards. The card contains the characteristics of your key (name, default value, type) that is used to access the storage. It is convenient to implement using the `enum` enumeration, but you can also use the usual `class`, which is certainly less convenient and more error-prone. Important: `Card.name` is used as a key within the SP, so if the name is changed, the data will be lost (virtually, but not physically).

### `Converter`

Converters are used to convert your object into a simple type that can be stored in storage. There are 5 basic types available:

| enum `DataType` | Basic Dart type |
|-----------------|-----------------|
| bool            | `bool`          |
| int             | `int`           |
| double          | `double`        |
| string          | `String`        |
| stringList      | `List<String>`  |

If the default value type specified in the card is not the Dart base type, you must provide the converter as a parameter when creating the `Cardoteka` instance. You can create your own converter based on the `Converter` class by implementing it. For collections, use `CollectionConverter` by extending it (or use `Converter`). However, many converters are already provided out of the box, including for collections.

| Converter                   | Representation of an object in storage |
|-----------------------------|----------------------------------------|
| `Converters`                |                                        |
| ->`_ColorConverter`         | `Color` as `int`                       |
| ->`_UriConverter`           | `Uri` as `String`                      |
| ->`_DurationConverter`      | `Duration` as `int`                    |
| ->`_DateTimeConverter`      | `DateTime` as `String`                 |
| ->`_DateTimeAsIntConverter` | `DateTime` as `int`                    |
| ->`_NumConverter`           | `num` as `double`                      |
| ->`_NumAsStringConverter`   | `num` as `String`                      |
| `Enum`                      |                                        |
| ->`EnumAsStringConverter`   | `Iterable<Enum>` as `String`           |
| ->`EnumAsIntConverter`      | `Iterable<Enum>` as `int`              |
| `CollectionConverter`       |                                        |
| ->`IterableConverter`       | `Iterable<E>` as `List<String>`        |
| ->`ListConverter`           | `List<E>` as `List<String>`            |
| ->`MapConverter`            | `Map<K, V>` as `List<String>`          |

### `Watcher`

I will mention `Watcher` and its implementation `WatcherImpl` separately. This is a very nice option that allows you to update your state based on the attached callback. The most important method is `attach`. Its essence is the ability to attach a `onChange` callback that will be triggered whenever a value is stored (`set` or `setOrNull` methods) in the storage. As parameters, you can specify:
- `onChange` -> to notify when a value is changed in storage (without comparison)
- `onRemove` ->  to notify when a value is removed from storage (`remove` or `removeAll` methods)
- `detacher` -> when listening no longer makes sense
- `fireImmediately` -> to fire `onChange` at the moment the `attach` method is called

Calling the `attach` method returns the actual value from storage OR the default value by card if none exists in storage. For `CardotekaAsync`, this method will first return the default value, and then return the actual value after the asynchronous operation is performed. Therefore, the `fireImmediately` flag is only relevant for `Cardoteka` instances. This behavior may change, keep an eye on [The `Watcher.attach` for `CardotekaAsync` instance first value returns a default value · Issue #38 · PackRuble/cardoteka](https://github.com/PackRuble/cardoteka/issues/38).

It is important to emphasize that you can implement your own solution based on `Watcher`.

### `Detachability`

The `Detachability` functionality is the ability to clear bound resources when `attach`ing and listening in a particular case is no longer needed. This has the same function as `close` in the `bloc` package, the `dispose` method in widgets and controllers, and the `ref.onDispose` method in the `riverpod` package. However, the `Detachability` mixin itself does not know how to clean up resources, but only contains a convenient `onDetach` method for storing callbacks and a `detach` method for deleting them later.

The `DetacherChangeNotifier` is a special case to be used in conjunction with `ChangeNotifier` for convenient use of the `onDetach` method in conjunction with `Watcher.attach(detacher: onDetach)`.

Check out examples of using `Detachability` functionality with different state managers in section ["Use with"](https://github.com/PackRuble/cardoteka?tab=readme-ov-file#use-with).

## Use with

All the most up-to-date examples can be found in the [example/lib](https://github.com/PackRuble/cardoteka/tree/dev/example/lib) folder of this project. Here are just some simple practices to use with different tools.

One common `AppCardoteka` instance and `AppSettings` cards are defined for all these cases. They look like this:
```dart
import 'package:cardoteka/cardoteka.dart';
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
  config: const CardotekaConfig(
    name: 'app_settings',
    cards: AppSettings.values,
    converters: AppSettings.converters,
  ),
);
```

### `ChangeNotifier`

There are several architectural options for using `Cardoteka` in conjunction with `ChangeNotifier`. Below we will consider the variant in which the `Cardoteka.attach` binding is used in the class constructor:

```dart
import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart';

import 'app_cardoteka.dart';

// I created an instance of Cardoteka and cards earlier, and here I'm just
// showing you their types and uses
final AppCardoteka cardoteka = appCardoteka;
const AppSettings<List<String>> card = AppSettings.recentActivityList;

/// An example of using [Cardoteka] with the [WatcherImpl] and
/// [DetacherChangeNotifier] mixins for the [ChangeNotifier] state class.
class ActivityNotifier with ChangeNotifier, DetacherChangeNotifier {
  ActivityNotifier() {
    cardoteka.attach(
      card,
      onChange: (value) {
        recentActivity = value;
        notifyListeners();
      },
      onRemove: () {
        recentActivity.clear();
        notifyListeners();
      },
      detacher: onDetach,
      fireImmediately: true,
    );
  }

  List<String> recentActivity = [];

  void addActivity(String text) =>
      cardoteka.set(card, [...recentActivity, text]);

  void removeActivities() => cardoteka.remove(card);
}
```

Important! Use `DetacherChangeNotifier` to properly dispose of all related data and pass `onDetach` method to `detacher` parameter of `attach` method. Next in widget I'll show you highlights, and you can find the full code at [example here](https://github.com/PackRuble/cardoteka/blob/dev/example/lib/change_notifier_with_cardoteka.dart).

```dart
class _RecentActivityAppState extends State<RecentActivityApp> {
  final _activityNR = ActivityNotifier();
  final _textCR = TextEditingController();

  @override
  void dispose() {
    _activityNR.dispose();
    _textCR.dispose();
    super.dispose();
  }

  void addRecord() {
    _activityNR.addActivity(_textCR.text);
    _textCR.clear();
  }

  @override
  Widget build(BuildContext context) {
    // ...
    ListenableBuilder(
      listenable: _activityNR,
      builder: (context, child) => ListView(
        children: [
          for (final activity in _activityNR.recentActivity.reversed)
            Text(activity),
        ],
      ),
    );
    // ...
    TextButton(
      onPressed: _activityNR.removeActivities,
      child: const Text('Delete all records'),
    );
    // ...
    TextField(
      controller: _textCR,
      onEditingComplete: addRecord,
    );
    // ...
    IconButton.filledTonal(
      onPressed: addRecord,
      icon: const Icon(Icons.add),
    );
    // ...
    
    return MaterialApp(/*...*/);
  }
}
```

![](https://github.com/PackRuble/cardoteka/blob/dev/res/changenotifier_with_cardoteka.png)

### `ValueNotifier`

Everything is very similar (and not surprising) to example with `ChangeNotifier`. However, we will consider a different architectural technique and take `attach`-connection outside the notifier. Let's define a notifier to implement the business logic to manage a user's premium subscription:
```dart
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
```

We still need the `DetacherChangeNotifier` mixin for proper resource utilization. Now:
```dart
Future<void> main() async {
  await Cardoteka.init();

  // We get a previously saved value from storage.
  // If isn't present, `card.defaultValue` will be returned.
  final isPremium = cardoteka.get(card);
  final premiumNR = PremiumNotifier(isPremium);
  print('1️⃣State is premium?: value=${premiumNR.value}');

  cardoteka.attach(
    card,
    onChange: (value) => premiumNR.value = value,
    onRemove: () => premiumNR.value = card.defaultValue,
    detacher: premiumNR.onDetach, // a line that allows you to fix memory leaks
  );

  await premiumNR.checkPremium();
  print('2️⃣State is premium?: value=${premiumNR.value}');

  await cardoteka.set(card, false);
  print('3️⃣State is premium?: value=${premiumNR.value}');

  premiumNR.dispose();
}
```

What happened?
1. Get current value from storage by card
2. console-> 1️⃣State is premium?: value=false
3. Attach a watcher to this card, which will notify the notifier about new values
4. Check premium on the server by calling `PremiumNotifier.checkPremium` method
5. console-> 2️⃣State is premium?: value=true
6. We save the new value to cardoteka, and after triggering watcher..:
7. console-> 3️⃣State is premium?: value=false

That is, roughly speaking, we can have very many notifiers with callbacks attached  that will automatically update the state after the values in the storage change.

### `Cubit` (bloc)

This is about using it in conjunction with the [bloc](https://pub.dev/packages/bloc) package. First we need to implement "detachability" (there are several options, all see [here](https://github.com/PackRuble/cardoteka/blob/dev/example/lib/cubit_with_cardoteka.dart)). It is more convenient if you determine it in the "general" place and will be used everywhere:

```dart
import 'package:bloc/bloc.dart' show Cubit;
import 'package:cardoteka/cardoteka.dart' show Detachability;
import 'package:meta/meta.dart' show mustCallSuper;

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
```

Now let's create a cubit that will be responsible for the theme of our application:
```dart
import 'package:bloc/bloc.dart';
import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart' show ThemeMode;

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
}
```

What happened?
1. Get current `themeMode` from storage by card
2. Create `CubitThemeMode` with actual `themeMode`
3. Attach a watcher to this card, which will notify the `CubitImpl` about new values
4. We save the new value to cardoteka, and after triggering watcher...
4. What does the `onNewTheme` method call...
5. And `CubitThemeMode` emit new state `ThemeMode.light`.

### `Provider` (riverpod)

This is about using it in conjunction with the [riverpod](https://pub.dev/packages/riverpod) package. First, you need to create a "Cardoteka" provider for your storage instance and your desired state provider:

```dart
import 'package:cardoteka/cardoteka.dart';
import 'package:riverpod/riverpod.dart';

import 'app_cardoteka.dart';

// I created an instance of Cardoteka and cards earlier, and here I'm just
// showing you their types and uses
final cardotekaProvider = Provider((_) => appCardoteka);
const AppSettings<HomePageState> card =
    AppSettings.homePageState; // with defaultValue=HomePageState.unknown

final homePageStateProvider = Provider<HomePageState>(
  (ref) => ref.watch(cardotekaProvider).attach(
    card,
    onChange: (value) => ref.state = value,
    onRemove: () => ref.state = HomePageState.unknown,
    detacher: ref.onDispose,
  ),
);
```

Note that using `StateProvider` is not necessary because the state change will occur automatically when the value in the store changes. Note also that we specify a callback in `onRemove` to update the provider state the moment the key-value pair is removed from storage.

The usage code will look like this:

```dart
Future<void> main() async {
  await Cardoteka.init();
  final container = ProviderContainer();
  final cardoteka = container.read(cardotekaProvider);

  HomePageState homePageState = container.read(homePageStateProvider);
  print('$homePageState'); // card.defaultValue-> HomePageState.unknown

  await cardoteka.set(card, HomePageState.open);
  homePageState = container.read(homePageStateProvider);
  print('$homePageState');
  // 1. a value was saved to storage
  // 2. the `onChange` callback we passed to `attach` is called.
  // 3. print-> HomePageState.open

  await cardoteka.remove(card);
  homePageState = container.read(homePageStateProvider);
  print('$homePageState');
  // 1. a value was removed from storage
  // 2. the function we passed to `onRemove` is called.
  // 3. print-> HomePageState.unknown
}
```

### `Notifier` (riverpod)

This is about using it in conjunction with the [riverpod](https://pub.dev/packages/riverpod) package. Create a notifier to work with the current locale:

```dart
import 'package:cardoteka/cardoteka.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

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
```

Note how convenient it is to pass `ref.onDispose` to `detacher` when `attach`ing a listener to a storage: as soon as the current notifier is disposed of, it will also clear the associated resources in storage. 

Below is the simplest application to change the locale of your application:

```dart
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
```

With this mini application, we can select locale, see localized text, and reset locale. And thanks to the `attach`ed `onChange` callback, all you need to do is save/delete a value in storage so that state of ALL notifiers is updated in a timely manner. All this makes it possible to use a large number of notifiers and not worry that some of them are left with an irrelevant state. Check the launch of this application [here](https://github.com/PackRuble/cardoteka/blob/dev/example/lib/riverpod_provider_cardoteka.dart).

The `AsyncNotifier` is used in the same way.

## Migration

### Cardoteka from v1 to v2

I tried to make the transition from version 1 as gentle as possible AND still very productive on new features. 

1. **All declarations of own classes from `Cardoteka` and `CardotekaAsync` (new) must now necessarily be declared as `final` or `base` or `sealed`.**

2. **The `Watcher.attach` method is updated.**

Before:
```dart
cardoteka.attach(
  card,
  (value) {/* Do something with the new value */},
  onRemove: () {/* Was optional */},
);
```

After:
```dart
cardoteka.attach(
  card,
  onChange: (value) {/* This parameter is now named */},
  onRemove: () {/* This parameter is now required */},
);
```

3. **The `AccessToSP` has been deleted.** Use `import package:cardoteka/access_to_sp.dart`.

4. **Data migration**

Migration version 2 must be carried out if:
- you previously used `cardoteka` package version `1.*.*`;
- you previously used `shared_preferences` version `2.3.0` and lower;

Then do the following and it will automatically migrate your data:
```dart
await CardotekaMigrator.migrate();
// and then the usual actions
await Cardoteka.init();
```
By default, all your entries from the old version of the storage will be moved to the new one (old storage will be cleared). 

If you need more control over the process, you can define your own handler for each entry:
```dart
await CardotekaMigrator.migrate(
  toV2Handler: (key, value) => (key, value, removeOld: false, ignore: false),
);
```

If you don't need migration, then either don't call this method, or do this:
```dart
await CardotekaMigrator.migrate(toV2Handler: null);
```

The result `HandlerEntryV2` of executing `toV2Handler` shows what should be done with the given entry.

`HandlerEntryV2` represents a record resulting from the execution of a data migration handler.
Her parameters:
- `key` a new key associated with a value that will be stored in storage.
- `value` a new value associated with a key that will be stored in storage. If the `HandlerEntryV2.value` is null, no write to the new storage will occur.
- `removeOld` allows you to delete an entry from the old storage.
- `ignore` completely ignores this entry.

*Let's deal with some special cases*. Suppose you needed:
- `fcm_vapid_key` save in new storage and leave in old storage
- `platform_available_memory_mb` ignore for new storage and leave in old storage
- `theme_mode_index` change name to 'user_settings.themeModeApp' and change value from `1` to `light` and delete from old storage

Moreover, we would like to use the `user_settings.themeModeApp` key later on as `Card` with `Cardoteka`. To do this, add the name specified in `CardotekaConfig` and the dot `.` to the key in the prefix. 

And if your configuration looks like this:
```dart
const config = CardotekaConfig(
  name: 'user_settings',
  cards: [/* .., StorageCard.themeModeApp .., */],
);
```

In addition to this, you have used Cardoteka before and there are also keys (cards) stored there that will simply be move to new storage:
- `user_settings.isPremium`
- `user_settings.userName`

Everything in general can be done like this:
```dart
await CardotekaMigrator.migrate(
  toV2Handler: (key, value) => switch (key) {
    'fsm_vapid_key' => (key, value, removeOld: false, ignore: false),
    'platform_available_memory_mb' => (key, value, removeOld: false, ignore: true),
    'theme_mode_index' => (
        '${config.name}.themeModeApp',
        switch (value) {
          1 => ThemeMode.light,
          2 => ThemeMode.dark,
          _ => ThemeMode.system,
        }
            .name,
        removeOld: true,
        ignore: false,
      ),
    // for all other keys
    _ => (key, value, removeOld: true, ignore: false),
  },
);
// It was before migration in old storage:
// {
//   'fsm_vapid_key': 'BKagOny0KF_2pCJQ3mmoL0ewzQ8rZu',
//   'platform_available_memory_mb': 2119.3,
//   'theme_mode_index': 1,
// };
// and at the same time in new storage:
// {
//   'user_settings.isPremium': true,
//   'user_settings.userName': 'Ivan',
// };
//
//
// Now after migration in old storage:
// {
//   'fsm_vapid_key': 'BKagOny0KF_2pCJQ3mmoL0ewzQ8rZu',
//   'platform_available_memory_mb': 2119.3,
// };
// and in new storage:
// {
//   'fsm_vapid_key': 'BKagOny0KF_2pCJQ3mmoL0ewzQ8rZu',
//   'user_settings.themeModeApp': 'light',
//   'user_settings.isPremium': true,
//   'user_settings.userName': 'Ivan',
//   '_cardoteka_package_did_migrate_v2': true,
// };
```

Note! Depending on the platform, the old and new storage may overlap.
This method potentially takes this into account.

The migration will result in an entry with the `_cardoteka_package_did_migrate_v2` key
in storage about the status of the current migration.

## Obfuscate

At the time of writing, the [documentation](https://docs.flutter.dev/deployment/obfuscate#caveat) states that obfuscation does not apply to `Enum`:

> Enum names are not obfuscated currently.

However, this behavior may change in the future. So for now you can safely use `String get key => name;` as keys for your cards.

## Coverage

The most important "core" is covered by the tests part and all the places that needed covering in my opinion. There are badges at the very beginning of the current file where you can see the percentage of coverage, among other things. Or, click on the image below. It's relevant for releases. 

[codecov_tree_badge]: https://codecov.io/gh/PackRuble/cardoteka/graphs/tree.svg
[codecov_sunburst_badge]: https://codecov.io/gh/PackRuble/cardoteka/graphs/sunburst.svg

| [![codecov_tree_badge]][codecov_link] | [![codecov_sunburst_badge]][codecov_link] |
|---------------------------------------|-------------------------------------------|

## Author

You can contact me or check out my activities on the following platforms:

- [Github](https://github.com/PackRuble)
- [Telegram Group](https://t.me/+AkGV73kZi_Q1YTMy)
- [StackOverflow](https://stackoverflow.com/users/17991131/ruble)
- [Medium](https://medium.com/@pack.ruble)
- [Habr](https://habr.com/ru/users/PackRuble/)

> Stop thinking that something is impossible. Make your dreams come true! Move towards your goal as if the quality of your code depends on it! And of course, use good libraries❣️
> 
> With respect to everyone involved, Ruble.

[telegram_badge]: https://img.shields.io/badge/Telegram_channel-❤️-_?style=plastic&logo=telegram&color=33cccc
[telegram_link]: https://t.me/+AkGV73kZi_Q1YTMy

[pub_likes]: https://img.shields.io/pub/likes/cardoteka?style=plastic&logo=flutter&color=c24641
[pub_badge]: https://img.shields.io/pub/v/cardoteka.svg?style=plastic&logo=dart
[pub_link]: https://pub.dev/packages/cardoteka

[codecov_badge]: https://img.shields.io/codecov/c/github/PackRuble/cardoteka?style=plastic&color=00cc00&logo=codecov
[codecov_link]: https://app.codecov.io/gh/PackRuble/cardoteka

[license_badge]: https://img.shields.io/github/license/PackRuble/cardoteka?style=plastic&logo=apache&color=996600
[license_link]: https://github.com/PackRuble/cardoteka/blob/dev/LICENSE

[code_size_badge]: https://img.shields.io/github/languages/code-size/PackRuble/cardoteka?style=plastic&color=339966
[repo_link]: https://github.com/PackRuble/cardoteka

[repo_star_badge]: https://img.shields.io/github/stars/packruble/cardoteka?style=plastic&logo=github&color=DAA520
[repo_star_link]: https://github.com/PackRuble/cardoteka/network/dependents

[pub_like_icon]: https://pub.dev/static/hash-ffjootqp/img/like-active.svg