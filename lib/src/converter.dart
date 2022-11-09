/// Use to transform a complex model.
abstract class RConverter<T, S> {
  const RConverter();

  T fromDb(S value);
  S toDb(T object);
}
