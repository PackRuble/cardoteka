<a href="https://github.com/PackRuble/cardoteka/"><img src="https://github.com/PackRuble/cardoteka/blob/master/res/cardoteka_banner.png?raw=true"/></a>

## Cardoteka

[![telegram_badge]][telegram_link]
[![pub_badge]][pub_link]
[![codecov_badge]][codecov_link]
[![license_badge]][license_link]
[![code_size_badge]][repo_link]
[![repo_star_badge]][repo_star_link]

⭐️ The best type-safe wrapper over SharedPreferences.

## Advantages

Why should I prefer to use [`cardoteka`](https://pub.dev/packages/cardoteka) instead of the original [`shared_preferences`](https://pub.dev/packages/shared_preferences)? The reasons are as follows:
- 🧭 your keys and default values are stored in a systematic and organized manner. You don't have to think about where to stick them.
- 🎼 use `get` or `set` instead of a heap of `getBool`, `setDouble`, `getInt`, `getStringList`, `setString`... Think about the entities being stored, not how to store or retrieve them.
- 📞 update the state as soon as new data arrives in the storage. No to code duplication - use `Watcher`.
- 🧯 have to frequently check the value for null before saving? Use the `getOrNull` and `setOrNull` methods and don't worry about anything!
- 🚪 do you still need access to dynamic methods from the original library? It's still there if you specify `with AccessToSP`.

## Table of contents

<!-- TOC -->
  * [Cardoteka](#cardoteka)
  * [Advantages](#advantages)
  * [Table of contents](#table-of-contents)
  * [How to use?](#how-to-use)
  * [Use with...](#use-with)
    * [ChangeNotifier](#changenotifier)
    * [ValueNotifier](#valuenotifier)
    * [Cubit (bloc)](#cubit-bloc)
    * [Provider (riverpod)](#provider-riverpod)
  * [Structure](#structure)
    * [Cardoteka](#cardoteka-1)
    * [Card](#card)
    * [Converter](#converter)
    * [Watcher](#watcher)
  * [Coverage](#coverage)
  * [Author](#author)
<!-- TOC -->

## How to use?

1. Define your cards: specify the type to be stored and the default value. Additionally, specify converters if the value type cannot be represented in the existing `DataType` enumeration:

```dart
import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart' hide Card;

enum SettingsCards<T extends Object> implements Card<T> {
   userColor(DataType.int, Color(0x00FF4BFF)),
   themeMode(DataType.string, ThemeMode.light),
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

```

2. Define storage for cards and mix in functionality as you see fit:

```dart
class SettingsCardoteka extends Cardoteka with WatcherImpl {
  SettingsCardoteka({required super.config});
}
```

3. Perform initialization (once) via `Cardoteka.init` and take advantage of all the features of your cardoteka: save, read, delete, listen to your saved data using typed cards:

```dart
main() async {
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
```

**Don't worry!** If you do something wrong, you will receive a detailed correction message in the console.

## Use with...

All the most up-to-date examples can be found in the [example/lib](https://github.com/PackRuble/cardoteka/tree/dev/example/lib) folder of this project. Here are just some simple practices to use with different tools.

### ChangeNotifier

You will need a notifier (by the way, stop extending on it. Use `with` instead of `extends`) and one helper method for caching callbacks for later calling them when the notifier is disposed. For now, you can implement this yourself as a mixin:

```dart
mixin NotifierDetacher on ChangeNotifier {
  List<VoidCallback>? _onDisposeCallbacks;

  void onDispose(void Function() cb) {
    _onDisposeCallbacks ??= [];
    _onDisposeCallbacks!.add(cb);
  }

  @override
  void dispose() {
    _onDisposeCallbacks?.forEach((cb) => cb.call());
    _onDisposeCallbacks = null;

    super.dispose();
  }
}
```

This feature "from the package" will be implemented later. Now you can take part in the [discussion #9](https://github.com/PackRuble/cardoteka/issues/9) (🥺) of the API of this aspect.

Now you can define your notifier with the required number of states and then `attach` a callback (you can attach as many callbacks to the card as you like):

```dart
import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart' hide Card;

class OrderNotifier with ChangeNotifier, NotifierDetacher {
  final _orders = <String>[];

  void addOrder(String value) {
    _orders.add(value);
    notifyListeners();
    print('New order: $value');
  }
}

class CardotekaImpl = Cardoteka with WatcherImpl;

Future<void> main() async {
  await Cardoteka.init();
  // ignore_for_file: definitely_unassigned_late_local_variable
  // to☝️do: create an instance of cardoteka and pass configuration with cards
  late CardotekaImpl cardoteka;
  late Card<String> lastOrderCard;

  final notifier = OrderNotifier();
  cardoteka.attach(
     lastOrderCard,
     notifier.addOrder,
     detacher: notifier.onDispose,
  );

  await cardoteka.set(lastOrderCard, '#341');
  // 1. a value was saved to storage
  // 2. console-> New order: #341
}
```

### ValueNotifier

Everything is very similar (and not surprising, heh) to the example with `ChangeNotifier`. But instead of using `NotifierDetacher` let's implement this in a concrete class:

```dart
class CurrentTaskNotifier extends ValueNotifier {
  CurrentTaskNotifier(super.task);

  VoidCallback? _onDetach;

  void onDispose(void Function() cb) => _onDetach = cb;

  @override
  void dispose() {
    _onDetach?.call();
    super.dispose();
  }
}
```

Now all the same ingredients, but let's also add the `fireImmediately` flag to get the actual value in our notifier at once:

```dart
import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart' hide Card;

class CardotekaImpl = Cardoteka with WatcherImpl;

Future<void> main() async {
  await Cardoteka.init();
  // ignore_for_file: definitely_unassigned_late_local_variable
  // to☝️do: create an instance of cardoteka and pass configuration with cards
  late CardotekaImpl cardoteka;
  late Card<String> card; // with default value = 'no business...'

  final notifier = CurrentTaskNotifier('');
  cardoteka.attach(
    card,
    (value) {
      notifier.value = value;
      print('New case: $value');
    },
    detacher: notifier.onDispose, // attention to this line
    fireImmediately: true, // callback will fire immediately
  );

  await cardoteka.set(card, 'new case available!');
  // 1. console-> New case: no business...
  // 2. a value was saved to storage
  // 3. console-> New case: new case available!
}
```

However, if you don't like throwing empty values (perhaps adhering to the "don't use magic constants" principle), then use this option (fully equivalent):

```dart
final notifier = CurrentTaskNotifier(card.defaultValue);
cardoteka.attach(
  card,
  (value) {
    notifier.value = value;
    print('New case: $value');
  },
  detacher: notifier.onDispose,
);
```

### Cubit (bloc)

This is about using it in conjunction with the [bloc](https://pub.dev/packages/bloc) package. First we need to implement "detachability":

```dart
import 'package:flutter/foundation.dart' show VoidCallback;
import 'package:meta/meta.dart' show protected;

/// Perhaps this mixin will be included in the package in one form or another...
mixin Detachability {
  List<VoidCallback>? _onDisposeCallbacks;

  void onDetach(void Function() cb) {
    _onDisposeCallbacks ??= [];
    _onDisposeCallbacks!.add(cb);
  }

  @protected
  void detach() {
    _onDisposeCallbacks?.forEach((cb) => cb.call());
    _onDisposeCallbacks = null;
  }
}
```

Participate in the discussion (🙏) to implement such functionality into the package: [Way to remove a callback using `Watcher.attach` + `Cubit` · Issue #10 · PackRuble/cardoteka](https://github.com/PackRuble/cardoteka/issues/10).

Next we define our cubit and logic, chain `Detachability` to it and override the behavior of the `close` method:

```dart
import 'package:bloc/bloc.dart';

class CubitImpl extends Cubit<int> with Detachability {
  CubitImpl(super.initialState);

  void setValue(int value) => emit(value);

  @override
  void onChange(Change<int> change) {
    super.onChange(change);
    print('Value has been changed:${change.currentState}->${change.nextState}');
  }

  @override
  Future<void> close() async {
    super.detach();
    return super.close();
  }
}
```

We can now interact with `Cardoteka` in this way:

```dart
import 'package:cardoteka/cardoteka.dart';

class CardotekaImpl = Cardoteka with WatcherImpl;

Future<void> main() async {
  await Cardoteka.init();
  // ignore_for_file: definitely_unassigned_late_local_variable
  // to☝️do: create an instance of cardoteka and pass configuration with cards
  late CardotekaImpl cardoteka;
  late Card<int> counterCard; // defaultValue = 99

  final cubit = CubitImpl(counterCard.defaultValue);
  cardoteka.attach(
    counterCard,
    cubit.setValue,
    detacher: cubit.onDetach,
  );

  await cardoteka.set(counterCard, 321);
  // 1. a value was saved to storage
  // 2. console-> Value has been changed:99->321
}
```

### Provider (riverpod)

This is about using it in conjunction with the [riverpod](https://pub.dev/packages/riverpod) package. First, you need to create a provider to `Cardoteka` an instance of your onboarding and a provider of your desired state:

```dart
import 'package:cardoteka/cardoteka.dart';
import 'package:riverpod/riverpod.dart';

// ignore_for_file: definitely_unassigned_late_local_variable
// to☝️do: create an instance of cardoteka and pass configuration with cards
late CardotekaImpl cardoteka;
late Card<RoomDoorState> doorStateCard; // defaultValue = RoomDoorState.ajar

final cardotekaProvider = Provider<CardotekaImpl>((ref) {
  return cardoteka;
});

final doorStateProvider = Provider<RoomDoorState>((ref) {
  return ref.watch(cardotekaProvider).attach(
        doorStateCard,
        (value) => ref.state = value,
        onRemove: () => ref.state = RoomDoorState.unknown,
        detacher: ref.onDispose,
      );
});
```

Note that using `StateProvider` is not necessary because the state change will occur automatically when the value in the store changes.

The usage code will look like this:

```dart
Future<void> main() async {
  await Cardoteka.init();
  final container = ProviderContainer();

  RoomDoorState doorState = container.read(doorStateProvider);
  print('$doorState'); // lastOrderCard.defaultValue-> RoomDoorState.ajar

  await container.read(cardotekaProvider).set(doorStateCard, RoomDoorState.open);
  doorState = container.read(doorStateProvider);
  print('$doorState');
  // 1. a value was saved to storage
  // 2. the callback we passed to `attach` is called.
  // 3. print-> RoomDoorState.open

  await container.read(cardotekaProvider).remove(doorStateCard);
  doorState = container.read(doorStateProvider);
  print('$doorState');
  // 1. a value was removed from storage
  // 2. the function we passed to `onRemove` is called.
  // 3. print-> RoomDoorState.unknown
}
```

## Structure

The structure of the library is very simple! Below are the main classes you will have to work with.

| Basic elements of Cardoteka | Purpose                                       |
|-----------------------------|-----------------------------------------------|
| `Card`                      | Key to the storage to interact with it        |
| `CardotekaConfig`           | Configuration file for a Cardoteka instance   |
| `Converter` & `Converters`  | Transforming objects to interact with storage |

### Cardoteka

Main class for implementing your own storage instance. Contains all the basic methods for working with SharedPreferences in a typed style. Serves as a wrapper over SP. Use as many implementations (and instances) as needed, passing a unique name in the parameters. Use mixins to extend functionality.

| Mixin for `Cardoteka`    | Purpose                                     |
|--------------------------|---------------------------------------------|
| `Watcher`<-`WatcherImpl` | To implement wiretapping based on callbacks |
| `AccessToSP`             | To access the original `SharedPreferences`  |
| `CRUD`                   | To simulate crud operations                 |


### Card

Every instance of Cardoteka needs cards. The card contains the characteristics of your key (name, default value, type) that is used to access the storage. It is convenient to implement using the `enum` enumeration, but you can also use the usual `class`, which is certainly less convenient and more error-prone. Important: `Card.name` is used as a key within the SP, so if the name is changed, the data will be lost (virtually, but not physically).

### Converter

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

### Watcher

I will mention `Watcher` and its implementation `WatcherImpl` separately. This is a very nice option that allows you to update your state based on the attached callback. The most important method is `attach`. Its essence is the ability to attach a `callback` that will be triggered whenever a value is stored (`set` or `setOrNull` methods) in the storage. As parameters, you can specify:
- `onRemove` ->  to notify when a value is removed from storage (`remove` or `removeAll` methods)
- `detacher` -> when listening no longer makes sense
- `fireImmediately` -> to fire `callback` at the moment the `attach` method is called

Calling the `attach` method returns the actual value from storage OR the default value by card if none exists in storage.

It is important to emphasize that you can implement your own solution based on `Watcher`.

## Coverage

The most important "core" is covered by the tests part and all the places that needed covering in my opinion. There are badges at the very beginning of the current file where you can see the percentage of coverage, among other things. Or, click on the image below. It's relevant for releases. 

[![](https://codecov.io/gh/PackRuble/cardoteka/graphs/sunburst.svg?token=IKB7AEHZPL)][codecov_link]

## Author

You can contact me or check out my activities on the following platforms:

- [Github](https://t.me/+AkGV73kZi_Q1YTMy)
- [Telegram Group](https://t.me/+AkGV73kZi_Q1YTMy)
- [StackOverflow](https://stackoverflow.com/users/17991131/ruble)
- [Medium](https://medium.com/@pack.ruble)
- [Habr](https://habr.com/ru/users/PackRuble/)

> Stop thinking that something is impossible. Make your dreams come true! Move towards your goal as if the quality of your code depends on it! And of course, use good libraries❣️
> 
> With respect to everyone involved, Ruble.

[telegram_badge]: https://img.shields.io/badge/Telegram%20channel-❤️-_?style=plastic&logo=telegram&color=33cccc
[telegram_link]: https://t.me/+AkGV73kZi_Q1YTMy

[pub_badge]: https://img.shields.io/pub/v/cardoteka.svg?style=plastic
[pub_link]: https://pub.dev/packages/cardoteka

[codecov_badge]: https://img.shields.io/codecov/c/github/PackRuble/cardoteka/master?style=plastic&color=00cc00&logo=codecov
[codecov_link]: https://app.codecov.io/gh/PackRuble/cardoteka

[license_badge]: https://img.shields.io/github/license/PackRuble/cardoteka?style=plastic&color=996600
[license_link]: https://github.com/PackRuble/cardoteka/blob/master/LICENSE

[code_size_badge]: https://img.shields.io/github/languages/code-size/PackRuble/cardoteka?style=plastic&color=339966
[repo_link]: https://github.com/PackRuble/cardoteka

[repo_star_badge]: https://img.shields.io/github/stars/PackRuble/cardoteka?style=plastic
[repo_star_link]: https://github.com/PackRuble/cardoteka/network/dependents
