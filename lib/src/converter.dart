// todo: This is how you can convert Color in reactive_db ^)

import 'package:flutter/material.dart';

extension SaveColor on Color {
  String toDb() => value.toString();

  Color fromDb(String value) => Color(int.parse(value));
}

methodName() {
  const color = Colors.blue;

  color.toDb();

  color.fromDb('value');
}
