import 'package:cardoteka/cardoteka.dart';

enum SettingsCard<T extends Object?> implements Card<T> {
  isPremium(DataType.bool, false),
  premiumPurchaseDay<DateTime?>(DataType.string, null),
  ;

  const SettingsCard(this.dartType, this.defaultValue);

  @override
  final DataType dartType;

  @override
  final T defaultValue;

  @override
  String get key => name;

  static const converters = <Card, Converter>{
    premiumPurchaseDay: DateTimeConverter(),
  };
}

void main() async {
  final cardoteka = Cardoteka(
    config: const CardotekaConfig(
      cards: SettingsCard.values,
      converters: SettingsCard.converters,
    ),
    storage: MemoryStorage(),
  );

  final isPremium = cardoteka.getOrDefault(SettingsCard.isPremium);
  if (!isPremium) {
    // Well, we'll buy it today.
    // ignore_for_file: avoid_print
    await Future.delayed(const .new(seconds: 5), () => print('Bought!'));
    cardoteka.set(SettingsCard.premiumPurchaseDay, DateTime.timestamp());

    final date = cardoteka.get(SettingsCard.premiumPurchaseDay);
    print('Congratulations, the premium was purchased on $date!');
  }
}
