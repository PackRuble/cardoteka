import 'package:cardoteka/cardoteka.dart' show Converter;

class Model {
  const Model();
}

class ModelConverter implements Converter<Model, String> {
  const ModelConverter();

  @override
  Model from(_) => const Model();

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
  Time from(int data) => Time(DateTime.fromMillisecondsSinceEpoch(data));

  @override
  int to(Time object) => object.value.millisecondsSinceEpoch;
}

class List2DConverterStub
    implements Converter<List<List<Object?>>, String> {
  const List2DConverterStub();
  @override
  List<List<Object?>> from(_) => [];

  @override
  String to(_) => '123';
}
