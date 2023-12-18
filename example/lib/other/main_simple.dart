import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart' hide Card;

class DbUser extends Cardoteka with WatcherImpl {
  DbUser({required super.config});
}

/// Storage of [Enum] type with possibility of using custom key.
enum Cards<T> implements Card<T> {
  banana<int>(DataType.int, 5),
  melon<int?>(DataType.int, 44),
  cucumber<int>(DataType.int, -3),
  watermelon<int>(DataType.int, 2),
  ;

  const Cards(this.type, this.defaultValue);

  @override
  final DataType type;

  @override
  final T defaultValue;

  @override
  String get key => name;

  static CardotekaConfig get config => const CardotekaConfig(
        name: 'KeyStore',
        cards: values,
      );
}

Future<void> main() async {
  await Cardoteka.init();
  final DbUser db = DbUser(config: Cards.config);

  // If there is no value, it will return the default value.
  // Will always return the type specified in the key.
  final banana = db.get(Cards.banana);
  print(banana);

  // You can specify [ifAbsent] if you want to return your value
  // instead of [defaultValue] in case the key is absent in the database.
  final bananaNull = db.get(Cards.banana);
  print(bananaNull);

  // When you save a new value to the database, be sure to specify the generic type.
  await db.set(
      Cards.banana, 5); // says it's not a mistake (it's really not a mistake)
  await db.set(Cards.banana, 'mistake!'); // says it's not a mistake
  await db.set(Cards.banana, true); // says it's not a mistake
  await db.set<int>(Cards.banana, 5); // right call
  // db.set<int>(KeyStore.banana, 'mistake!'); // a mistake
  // db.set<bool>(KeyStore.banana, true); // a mistake (KeyStore.banana is int type)

  db.attach(
    Cards.banana,
    (value) => print('$value - we know the number of bananas'),
    detacher: (_) {},
  );

  runApp(const MaterialApp());
}