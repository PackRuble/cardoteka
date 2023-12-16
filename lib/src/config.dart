import 'package:meta/meta.dart';

import 'card.dart';
import 'converter.dart';

/// Configuration model for the [Cardoteka] impl.
@immutable
class CardotekaConfig {
  const CardotekaConfig({
    required this.name,
    required this.cards,
    this.converters,
  });

  /// The name of your [Cardoteka] instance. The [name] must be unique and
  /// not used in other instances.
  ///
  /// Under the hood, the name is used as prefixes for all [cards].
  final String name;

  /// List of all key-cards to access [SharedPreferences] in [Cardoteka].
  final List<Card> cards;

  /// Map of converters for complex objects (those whose types are not part of
  /// the basic set to save).
  ///
  /// For each [Card], add a [Converter] if necessary.
  final Map<Card<Object?>, Converter<Object?, Object>>? converters;

  // todo: Future feature: final migrator;

  @override
  String toString() =>
      '$CardotekaConfig(name: $name, \ncards: $cards, \nconverters: $converters)';
}
