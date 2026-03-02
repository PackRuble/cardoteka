import 'package:cardoteka/cardoteka.dart' show Converter;

enum Theme { blue, green, orange }

// todo(01.03.2026, @PackRuble): del
class Model {
  const Model();
}

class User {
  const User(this.name, this.age);

  factory User.fromJson(Map<String, dynamic> map) =>
      User(map['name'] as String, map['age'] as int);

  final String name;
  final int age;

  Map<String, dynamic> toJson() => {'name': name, 'age': age};
}

class ModelConverter implements Converter<Model, String> {
  const ModelConverter();

  @override
  Model from(item) => const Model();

  @override
  String to(_) => '';
}

class Time {
  const Time(this.value);

  final DateTime value;

  factory Time.fromJson(Map<String, dynamic> json) =>
      Time(DateTime.parse(json['value'] as String));

  Map<String, dynamic> toJson() => {'value': value.toIso8601String()};
}

class TimeConverter implements Converter<Time, int> {
  const TimeConverter();

  @override
  Time from(int item) => Time(DateTime.fromMillisecondsSinceEpoch(item));

  @override
  int to(Time object) => object.value.millisecondsSinceEpoch;
}

class List2DConverterStub implements Converter<List<List<Object?>>, String> {
  const List2DConverterStub();
  @override
  List<List<Object?>> from(item) => [[], []];

  @override
  String to(_) => '123';
}
