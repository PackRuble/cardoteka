import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'db_provider.dart';

/// Shows how you can use [IConverter]

final myCarProvider = Provider<Car>((ref) {
  final db = ref.watch(dbProvider);

  return db.attach<Car>(
    KeyStore1.myCar,
    (value) => ref.state = value,
    detacher: null,
  );
}, name: 'myCarProvider');

final selectCarProvider = StateProvider<Car?>((ref) => null);

class DataModelWidget extends ConsumerWidget {
  const DataModelWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final Car? selectedCar = ref.watch(selectCarProvider);

    final Car carInGarage = ref.watch(myCarProvider);

    return Container(
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(8.0),
      ),
      constraints: BoxConstraints.tightFor(width: 500.0),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Select',
                onPressed: () => ref
                    .read(selectCarProvider.notifier)
                    .update((_) => getRandomCar()),
                icon: const Icon(Icons.car_crash_rounded),
              ),
              Text(selectedCar == null
                  ? '<-- Select car'
                  : 'Car --> brand: ${selectedCar.brand}, weight: ${selectedCar.weight} kg'),
              IconButton(
                tooltip: 'buy',
                onPressed: () {
                  selectedCar == null
                      ? ref.read(dbProvider).remove(KeyStore1.myCar)
                      : ref.read(dbProvider).set(KeyStore1.myCar, selectedCar);
                },
                icon: const Icon(Icons.save),
              ),
            ],
          ),
          const Divider(),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Garage(in DB): ${carInGarage.weight == 0.0 ? 'No car' : '$carInGarage'}'),
              IconButton(
                tooltip: 'Sell',
                onPressed: () => ref
                    .read(dbProvider)
                    .set(KeyStore1.myCar, KeyStore1.myCar.defaultValue),
                icon: const Icon(Icons.monetization_on_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static const Set<String> _brandsCar = {
    'Opel',
    'Lada',
    'Nissan',
    'Renault',
    'BMW',
    'Toyota'
  };

  Car getRandomCar() {
    final rd = Random();

    return Car(
      _brandsCar.elementAt(rd.nextInt(5)),
      1500.0 + rd.nextInt(2500),
    );
  }
}
