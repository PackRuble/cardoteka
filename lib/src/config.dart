import 'package:meta/meta.dart';

import 'card.dart';
import 'converter.dart';

/// Configuration model for the [Cardoteka] repository.
@immutable
class CardConfig {
  const CardConfig({
    required this.name,
    required this.cards,
    this.converters,
  });

  /// The name of your [Cardoteka] instance. The [name] must be unique and
  /// not used in other instances [Card].
  ///
  /// The name is used as a prefix for keys.
  final String name;

  /// List of all key-cards to access [SharedPreferences] in [Cardoteka].
  final List<Card> cards;

  /// Map of converters for complex objects (those whose types are not part of
  /// the basic set to save).
  ///
  /// For each card [Card], add the necessary [Converter].
  final Map<Card<Object?>, Converter<Object?, Object>>? converters;

  // Future feature: final migrator;

  @override
  String toString() =>
      '$CardConfig(name: $name, \ncards: $cards, \nconverters: $converters)';
}
