
## How to started?

1. Identify the DB object with the necessary mixins (optional)
   ```dart
   class DbUser extends RDatabase with CRUD, Watcher {}
   ```
2. Define your key list. Read more about all methods [here](#how-to-implement-key-storage)
   ```dart
   enum KeyStore<T> implements RKey<T> {
     banana<int>(TypeSaved.int, 5),
     melon<int?>(TypeSaved.int, 44),
     cucumber<int>(TypeSaved.int, -3),
     watermelon<int>(TypeSaved.int, 2),
     ;
   
     const KeyStore(this.type, this.defaultValue);
   
     @override
     final TypeSaved type;
   
     @override
     final T defaultValue;
   
     @override
     String get key => name;
   }
   ```
   
3. Initialize the database:
   ```dart
   final DbUser db = DbUser();
   await db.init(KeyStore.values);
   ```
4. Execute requests:
```dart
   // If there is no value, it will return the default value.
   // Will always return the type specified in the key.
   final banana = db.get(KeyStore.banana);
   print(banana);
   
   // You can specify [ifAbsent] if you want to return your value
   // instead of [defaultValue] in case the key is absent in the database.
   final bananaNull = db.get(KeyStore.banana, () => null);
   print(bananaNull);
   
   // When you save a new value to the database, be sure to specify the generic type.
   db.set(KeyStore.banana, 5); // says it's not a mistake (it's really not a mistake)
   db.set(KeyStore.banana, 'mistake!'); // says it's not a mistake
   db.set(KeyStore.banana, true); // says it's not a mistake
   db.set<int>(KeyStore.banana, 5); // right call
   db.set<int>(KeyStore.banana, 'mistake!'); // a mistake
   db.set<bool>(KeyStore.banana, true); // a mistake (KeyStore.banana is int type)
```

## How to use with Riverpod?
Use mixin `Watcher` and method `listen`
```dart

class DbUser extends RDatabase with Watcher {}

final db = Provider<DbUser>((ref) => DbUser());

// Note: if the value is absent in the database, the default value will be returned. 
// Pass also parameter onDispose if provider can be disposed. This will free up 
// related resources
final bananaProvider = Provider.autoDispose<int>((ref) {
    return ref.watch(db).listen<int>(
          KeyStore1.banana,
          (value) => ref.state = value,
          ref.onDispose,
        );
  });
```

And now we save the data to the database by our key  `KeyStore1.banana` using method:
```dart
// You can either pass ref as a parameter or use a class where that ref is an
// initialized field.
void saveValue(int value) =>
      ref.read(db).set(KeyStore1.banana, value);
```

As a result, the new value will be saved in the database `DbUser` and the provider `bananaProvider` will be automatically updated.

## How to implement key storage?

To create a key store, you need to use the `RKey` implementation.

The simplest way is to create an `Enum` of this form:
```dart
enum KeyStore<T> implements RKey<T> {
  carrot<int>(TypeSaved.int, 55),
  apple<int>(TypeSaved.int, 20),
  basket<String>(TypeSaved.string, 'Wooden basket'),
  // ...add what you need to keep
  ;

  const KeyStore(this.type, this.defaultValue);

  @override
  final TypeSaved type;

  @override
  final T defaultValue;

  @override
  String get key => name; // pay attention
}
```

This method assumes that the names of the `Enum` instances (e.g. `carrot`) will NEVER be changed. Otherwise, we will lose our data that was previously saved under this name.

#### There are several ways to avoid this mistake.
1. Always use custom keys for all objects:
    ```dart
    enum KeyStore<T> implements RKey<T> {
        ...
    [-] apple<int>(TypeSaved.int, 20),
    [+] apple<int>(TypeSaved.int, 20, 'custom key for carrot'),
      
        ...
    [-] const KeyStore(this.type, this.defaultValue);
    [+] const KeyStore(this.type, this.defaultValue, this.key);
    
        ...
    [-] String get key => name;
    [+] final String key;
    }
    ```
   
2. Use custom keys as needed:
    ```dart
   enum KeyStore<T> implements RKey<T> {
       ...
       carrot<int>(TypeSaved.int, 55),
       apple<int>(TypeSaved.int, 20, 'apple's need keys'),
 
   ...
   [-] const KeyStore(this.type, this.defaultValue);
   [+] const KeyStore(this.type, this.defaultValue, [this._key]);
   
   ...
   [+] final String? _key;
   
   ...
   [-] String get key => name;
   [+] String get key => _key ?? name;
   }
   ```
   
3. Add a key migration map and use the `@Deprecated('message')` annotation:
   ```dart
   ...
   @Deprecated(
    '`apple` are outdated. Use `greenApple` instead. '
    'For more information, consult the migration guide at .... '
    'This instance will be removed with the v3.0.0 release',
   )
   apple<int>(TypeSaved.int, 20),

   greenApple<int>(TypeSaved.int, 20),
   ...
   ```
   And add `{KeyStore.apple: KeyStore.greenApple}` in `Map<RKey, RKey>? migrator` to class `DbBase.init()` (in development).

With the help of a `class`, this can be done like this:
```dart
class KeyStore2<T> implements RKey<T> {
  static const carrot = KeyStore2<int>._(TypeSaved.int, 55, 'carrot');
  static const apple = KeyStore2<int>._(TypeSaved.int, 20, 'apple');
  static const gardenLocation = KeyStore2<String>._(
      TypeSaved.string, 'To the left of the lake', 'gardenLocation');

  static const List<KeyStore2> values = [carrot, apple, gardenLocation];

  const KeyStore2._(this.type, this.defaultValue, this.key);

  @override
  final TypeSaved type;

  @override
  final T defaultValue;

  @override
  final String key;
}
```

## TODO
1. [ ] Add info about watchers
2. [ ] Add info about operation instrument
3. [ ] Add info about convertes and complex objects
4. [ ] Add info about supported types
5. [ ] Add info uses maigrator


## Additional information

This project is under development and is actively 'undergoing combat' tests in applications
