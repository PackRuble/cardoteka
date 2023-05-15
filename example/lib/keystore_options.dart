// import 'package:cardoteka/cardoteka.dart';
//
// /// Conventional key store.
// enum KeyStore<T> implements ICard<T> {
//   carrot<int>(TypeData.int, 55),
//   apple<int>(TypeData.int, 20),
//   basket<String>(TypeData.string, 'Wooden basket'),
//   // ...add what you need to keep
//   ;
//
//   const KeyStore(this.type, this.defaultValue);
//
//   @override
//   final TypeData type;
//
//   @override
//   final T defaultValue;
//
//   @override
//   String get key => name; // pay attention
//
//   @override
//   CardConfig get config => CardConfig(name: 'KeyStore1');
// }
//
// /// Key store with optional custom key.
// enum KeyStore1<T> implements ICard<T> {
//   carrot<int>(TypeData.int, 55, 'carrot'),
//
//   @Deprecated(
//     '`apple` are outdated. Use `greenApple` instead. '
//     'For more information, consult the migration guide at .... '
//     'This instance will be removed with the v3.0.0 release',
//   )
//   apple<int>(TypeData.int, 20),
//   greenApple<int>(TypeData.int, 20),
//
//   basket<String>(TypeData.string, 'Wooden basket'),
//   ;
//
//   const KeyStore1(this.type, this.defaultValue, [this._key]);
//
//   @override
//   final TypeData type;
//
//   @override
//   final T defaultValue;
//
//   final String? _key;
//
//   @override
//   String get key => _key ?? name;
//
//   @override
//   CardConfig get config => CardConfig(name: 'KeyStore1');
// }
//
// class KeyStore2<T> implements ICard<T> {
//   static const carrot = KeyStore2<int>._(TypeData.int, 55, 'carrot');
//   static const apple = KeyStore2<int>._(TypeData.int, 20, 'apple');
//   static const gardenLocation = KeyStore2<String>._(
//       TypeData.string, 'To the left of the lake', 'gardenLocation');
//
//   static const List<KeyStore2> values = [carrot, apple, gardenLocation];
//
//   const KeyStore2._(this.type, this.defaultValue, this.key);
//
//   @override
//   final TypeData type;
//
//   @override
//   final T defaultValue;
//
//   @override
//   final String key;
//
//   @override
//   CardConfig get config => CardConfig(name: 'KeyStore1');
// }
