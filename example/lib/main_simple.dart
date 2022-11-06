import 'package:flutter/material.dart';
import 'package:reactive_db/reactive_db.dart';

class DbUser extends DbBase with Watcher {}

/// Storage of [Enum] type with possibility of using custom key.
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

Future<void> main() async {
  final DbUser db = DbUser();
  await db.init(KeyStore.values);

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
  // db.set<int>(KeyStore.banana, 'mistake!'); // a mistake
  // db.set<bool>(KeyStore.banana, true); // a mistake (KeyStore.banana is int type)

  runApp(const MaterialApp());
}
