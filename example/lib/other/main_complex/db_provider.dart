import 'dart:convert';

import 'package:cardoteka/cardoteka.dart';
import 'package:flutter/material.dart' hide Card;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dbProvider = Provider<DbUser>((ref) => DbUser(
      config: KeyStore1.config,
    ));

class DbUser extends Cardoteka with WatcherImpl, CRUD {
  DbUser({required super.config});
}

/// Storage of [Enum] type with possibility of using custom key.
enum KeyStore1<T> implements Card<T> {
  banana<int>(DataType.int, 0),
  counter1<int>(DataType.int, 0),
  counter2<int>(DataType.int, 0),
  counterCustom<int>(DataType.int, 2, 'custom_counter_key'),
  skyColor<Color>(DataType.string, Colors.blue),
  myCar<Car>(DataType.string, Car.notCar()),
  control<Controllability>(DataType.string, Controllability.easy),
  ;

  const KeyStore1(this.type, this.defaultValue, [this.customKey]);

  @override
  final DataType type;

  @override
  final T defaultValue;

  final String? customKey;

  @override
  String get key => customKey ?? EnumName(this).name;

  static CardConfig config = CardConfig(
    name: 'KeyStore1',
    cards: values,
    converters: {
      myCar: CarConverter(),
      skyColor: Converters.colorAsString,
      control: Converters.enumAsString(Controllability.values),
      control: Converters.enumAsInt(Controllability.values),
    },
  );
}

class CarConverter implements Converter<Car, String> {
  const CarConverter();

  @override
  Car from(String value) =>
      Car.fromJson(jsonDecode(value) as Map<String, dynamic>);

  @override
  String to(Car model) => jsonEncode(model.toJson());
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

enum Controllability { easy, medium, hard }
