import 'package:meta/meta.dart' show internal, reopen, visibleForTesting;

import 'data_type.dart';

// coverage:ignore-file

// Needed in testing and development.
// ignore_for_file: no_runtimeType_toString

// todo(22.02.2026, @PackRuble): doc
/// Cards for using the [CardotekaCore] implementation.
///
/// You may not specify a generic when implementing, in which case the type
/// will be inferred automatically based on the specified [defaultValue].
/// In general this works fine, however note that
/// if [defaultValue]=null then the inferred type will be [dynamic].
///
/// The card consists of:
/// - [dartType] -> type of data to be saved;
/// - [key] -> the cardoteka impl uses this key to access SharedPreferences;
/// - [defaultValue] -> default value for this key (for type [V]).
///
/// It is assumed to be implemented with [dc.Enum] for key definition. Here's an
/// uncomplicated example of simple data:
/// ```dart
/// enum SettingsCard implements Card<Object> {
///   homeIndex(DataType.int, 1),
///   relativePathSettings(DataType.string, r'%MYDOCUMENTS%\app_settings\'),
///   aspectLayout(DataType.double, 0.32),
///   listCodes(DataType.stringList, ['error', '403', '2030']),
///   ;
///
///   const SettingsCard(this.type, this.defaultValue);
///
///   @override
///   final DataType type;
///
///   @override
///   final Object defaultValue;
///
///   @override
///   String get key => name;
/// }
/// ```
/// For each card you can use a generic type and converters as needed.
///
/// However, a regular `class` will also work.
interface class Card<V extends Object?> {
  const Card.single(this.key, this.defaultValue, this.dartType);

  /// Type of data to be saved. Select the one that matches either the type
  /// of your [defaultValue] or the type after using the [Converter.to]
  /// converter method.
  final DataType<Object> dartType;

  /// The default value for this [Card].
  final V defaultValue;

  /// The key to access the value in the SharedPreferences store.
  final String key;

  @override
  String toString() => '$runtimeType(key: $key, '
      'defaultValue: $defaultValue, '
      'type: $dartType)';
}

/// Designed to allow inheritance during testing.
@reopen
@internal
@visibleForTesting
abstract class CardAbstract<T> extends Card<T> {
  @internal
  CardAbstract.single(
    super.key,
    super.defaultValue,
    super.dartType,
  ) : super.single();
}
