import 'package:meta/meta.dart';

import 'card.dart';
import 'converter.dart';

/// {@template cardoteka.CardotekaConfig}
/// Configuration model for working with `Cardoteka`.
/// Briefly:
/// - [CardotekaConfig.cards] list of all card keys for accessing the storage.
/// - [CardotekaConfig.converters] are used to convert a complex object to
/// the base types defined in the [DataType] enumeration.
/// {@endtemplate}
@immutable
class CardotekaConfig {
  const CardotekaConfig({
    required this.cards,
    this.converters,
  });

  /// List of all key-cards to access `CardotekaStorage`.
  final List<Card<Object?>> cards;

  /// Map of converters for complex objects (those whose types are not part of
  /// the basic set to save).
  ///
  /// For each [Card], add a [Converter] if necessary.
  final Map<Card<Object?>, Converter<Object?, Object?>>? converters;

  @override
  String toString() => ''
      '$CardotekaConfig('
      '\n  cards=$cards,'
      '\n  converters=$converters,'
      '\n)';
}
