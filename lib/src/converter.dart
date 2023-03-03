/// Use to transform a complex model for work to database.
abstract class IConverter<T, S> {
  const IConverter();

  T fromDb(S value);
  S toDb(T object);
}
