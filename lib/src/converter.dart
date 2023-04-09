/// Use to transform a complex model for work to database.
abstract class IConverter<V extends Object?, T extends Object> {
  const IConverter();

  V fromDb(T value);
  T toDb(V object);

  @override
  String toString() => 'fromDb: $V, toDb: $T';
}
