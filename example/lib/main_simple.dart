import 'package:flutter/material.dart';
import 'package:reactive_db/reactive_db.dart';

class DbUser extends CardDb with Watcher {
  DbUser({required super.cards});
}

/// Storage of [Enum] type with possibility of using custom key.
enum KeyStore<T> implements ICard<T> {
  banana<int>(TypeData.int, 5),
  melon<int?>(TypeData.int, 44),
  cucumber<int>(TypeData.int, -3),
  watermelon<int>(TypeData.int, 2),
  ;

  const KeyStore(this.type, this.defaultValue);

  @override
  final TypeData type;

  @override
  final T defaultValue;

  @override
  String get key => name;

  @override
  CardConfig get config => CardConfig(name: 'KeyStore1');
}

Future<void> main() async {
  final DbUser db = DbUser(cards: KeyStore.values);
  await db.init();

  // If there is no value, it will return the default value.
  // Will always return the type specified in the key.
  final banana = db.get(KeyStore.banana);
  print(banana);

  // You can specify [ifAbsent] if you want to return your value
  // instead of [defaultValue] in case the key is absent in the database.
  final bananaNull = db.get(KeyStore.banana);
  print(bananaNull);

  // When you save a new value to the database, be sure to specify the generic type.
  await db.set(KeyStore.banana,
      5); // says it's not a mistake (it's really not a mistake)
  await db.set(KeyStore.banana, 'mistake!'); // says it's not a mistake
  await db.set(KeyStore.banana, true); // says it's not a mistake
  await db.set<int>(KeyStore.banana, 5); // right call
  // db.set<int>(KeyStore.banana, 'mistake!'); // a mistake
  // db.set<bool>(KeyStore.banana, true); // a mistake (KeyStore.banana is int type)

  db.attach(
    KeyStore.banana,
    (value) => print('$value - we know the number of bananas'),
  );

  runApp(const MaterialApp());
}
