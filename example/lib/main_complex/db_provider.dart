import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_db/reactive_db.dart';

final dbProvider = Provider<DbUser>((ref) => DbUser());

class DbUser extends CardDb with Watcher, CRUD {
  DbUser() : super(cards: KeyStore1.values);
}

/// Storage of [Enum] type with possibility of using custom key.
enum KeyStore1<T> implements ICard<T> {
  banana<int>(TypeData.int, 0),
  counter1<int>(TypeData.int, 0),
  counter2<int>(TypeData.int, 0),
  counterCustom<int>(TypeData.int, 2, 'custom_counter_key'),
  skyColor<Color>(TypeData.color, Colors.blue),
  myCar<Car>(TypeData.string, Car.notCar()),
  ;

  const KeyStore1(this.type, this.defaultValue, [this.customKey]);

  @override
  final TypeData type;

  @override
  final T defaultValue;

  final String? customKey;

  @override
  String get key => customKey ?? EnumName(this).name;

  @override
  CardConfig get config => CardConfig(
        name: 'KeyStore1',
        converters: {KeyStore1.myCar: const CarConverter()},
      );
}

class CarConverter implements IConverter<Car, String> {
  const CarConverter();

  @override
  Car fromDb(String value) =>
      Car.fromJson(jsonDecode(value) as Map<String, dynamic>);

  @override
  String toDb(Car model) => jsonEncode(model.toJson());
}

class Car {
  const Car(this.brand, this.weight);

  final String brand;
  final double weight;

  factory Car.fromJson(Map<String, dynamic> json) =>
      Car(json['brand'] as String, json['weight'] as double);

  const Car.notCar() : this('', 0);

  Map<String, dynamic> toJson() => {'brand': brand, 'weight': weight};

  @override
  String toString() => 'Car($brand, $weight kg)';
}
