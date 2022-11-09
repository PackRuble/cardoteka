import 'package:reactive_db/reactive_db.dart';

/// Conventional key store.
enum KeyStore<T> implements RKey<T> {
  carrot<int>(TypeSaved.int, 55),
  apple<int>(TypeSaved.int, 20),
  basket<String>(TypeSaved.string, 'Wooden basket'),
  // ...add what you need to keep
  ;

  const KeyStore(this.type, this.defaultValue);

  @override
  final TypeSaved type;

  @override
  final T defaultValue;

  @override
  String get key => name; // pay attention
}

/// Key store with optional custom key.
enum KeyStore1<T> implements RKey<T> {
  carrot<int>(TypeSaved.int, 55, 'carrot'),

  @Deprecated(
    '`apple` are outdated. Use `greenApple` instead. '
    'For more information, consult the migration guide at .... '
    'This instance will be removed with the v3.0.0 release',
  )
  apple<int>(TypeSaved.int, 20),
  greenApple<int>(TypeSaved.int, 20),

  basket<String>(TypeSaved.string, 'Wooden basket'),
  ;

  const KeyStore1(this.type, this.defaultValue, [this._key]);

  @override
  final TypeSaved type;

  @override
  final T defaultValue;

  final String? _key;

  @override
  String get key => _key ?? name;
}

class KeyStore2<T> implements RKey<T> {
  static const carrot = KeyStore2<int>._(TypeSaved.int, 55, 'carrot');
  static const apple = KeyStore2<int>._(TypeSaved.int, 20, 'apple');
  static const gardenLocation = KeyStore2<String>._(
      TypeSaved.string, 'To the left of the lake', 'gardenLocation');

  static const List<KeyStore2> values = [carrot, apple, gardenLocation];

  const KeyStore2._(this.type, this.defaultValue, this.key);

  @override
  final TypeSaved type;

  @override
  final T defaultValue;

  @override
  final String key;
}
