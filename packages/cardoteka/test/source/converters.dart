import 'dart:convert' show jsonDecode, jsonEncode;

import 'package:cardoteka/cardoteka.dart'
    show Converter, IterableConverter, ListConverter, MapToListConverter;

import 'models.dart' show User;

mixin class UserConverter implements Converter<User, Map<String, dynamic>> {
  const UserConverter();

  @override
  User from(Map<String, dynamic> objRaw) => User.fromJson(objRaw);

  @override
  Map<String, dynamic> to(User obj) => obj.toJson();
}

final class UserListConverter = ListConverter<User, Map<String, dynamic>>
    with UserConverter;

final class UserIterableConverter = IterableConverter<User,
    Map<String, dynamic>> with UserConverter;

/// Values are assumed to be stored as a 'key[delimiter]value' string.
final class MapUserToListConverter
    extends MapToListConverter<String, User, String> {
  const MapUserToListConverter();

  static const delimiter = '::';

  @override
  MapEntry<String, User> from(String objRaw) {
    final list = objRaw.split(delimiter);

    return MapEntry(
      list.first,
      User.fromJson(jsonDecode(list.last) as Map<String, dynamic>),
    );
  }

  @override
  String to(MapEntry<String, User> obj) => ''
      '${obj.key}'
      '$delimiter'
      '${jsonEncode(obj.value.toJson())}';
}
