import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reactive_db/reactive_db.dart';

final dbProvider = Provider<DbUser>((ref) => DbUser());

class DbUser extends RDatabase with Watcher, CRUD {}

/// Storage of [Enum] type with possibility of using custom key.
enum KeyStore1<T> implements RKey<T> {
  banana<int>(TypeSaved.int, 0),
  counter1<int>(TypeSaved.int, 0),
  counter2<int>(TypeSaved.int, 0),
  counterCustom<int>(TypeSaved.int, 2, 'custom_counter_key'),
  skyColor<Color>(TypeSaved.color, Colors.blue),
  ;

  const KeyStore1(this.type, this.defaultValue, [this._customKey]);

  @override
  final TypeSaved type;

  @override
  final T defaultValue;

  final String? _customKey;

  @override
  String get key => _customKey ?? EnumName(this).name;
}
