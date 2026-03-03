import 'package:cardoteka/cardoteka.dart';
import 'package:cardoteka/cardoteka_flutter.dart' show DetacherChangeNotifier;
import 'package:flutter/foundation.dart';

final class GameCardoteka extends Cardoteka with WatcherImpl {
  GameCardoteka({required super.config, required super.storage});

  // 1. сan do it without the G, because there are few advantages
  Map<CardT, G> attachMap<CardT extends Card<G>, G extends Object?>(
    List<CardT> values, {
    required void Function(Map<CardT, G> change) onChange,
    required void Function(List<CardT> cards) onRemove,
    required Detacher detacher,
    required bool fireImmediately,
  }) {
    // task(03.03.2026, @PackRuble): #18 Implementation of attachAll in Watcher
    throw UnimplementedError();
  }
}

enum GameCard<T extends Object> implements Card<T> {
  quizzesPlayed<List<String>>(DataType.list, []),
  winning(DataType.int, 0),
  losing(DataType.int, 0);

  const GameCard(this.dartType, this.defaultValue);

  @override
  final DataType dartType;

  @override
  final T defaultValue;

  @override
  String get key => name;
}

enum Difficulty { easy, medium, hard }

enum Category { animals, politics, sport }

class GameStats {
  late Map<Difficulty, Duration> timeSpentByDifficulty;
  late Map<Category, Duration> timeSpentByCategory;
  late List<String> quizzesPlayed;
  late int winning;
  late int losing;
}

class QuizStatsNotifier extends ChangeNotifier with DetacherChangeNotifier {
  QuizStatsNotifier(this._cardoteka) {
    // _init1variant();
    _init2variant();
  }

  late GameCardoteka _cardoteka;
  late GameStats state;

  void _init1variant() {
    state = GameStats()
      ..quizzesPlayed = _cardoteka.attach(
        GameCard.quizzesPlayed,
        onChange: (quizzes) {
          final (byDifficulty, byCategory) = _calcAll(quizzes);
          state
            ..quizzesPlayed = quizzes
            ..timeSpentByDifficulty = byDifficulty
            ..timeSpentByCategory = byCategory;
          notifyListeners();
        },
        detacher: onDetach,
        onRemove: () {
          state
            ..quizzesPlayed = GameCard.quizzesPlayed.defaultValue
            ..timeSpentByDifficulty = {}
            ..timeSpentByCategory = {};
          notifyListeners();
        },
        fireImmediately: true,
      )
      ..winning = _cardoteka.attach(
        GameCard.winning,
        onChange: (value) {
          state.winning = value;
          notifyListeners();
        },
        detacher: onDetach,
        onRemove: () {
          state.winning = GameCard.winning.defaultValue;
          notifyListeners();
        },
      )
      ..losing = _cardoteka.attach(
        GameCard.losing,
        onChange: (value) {
          state.losing = value;
          notifyListeners();
        },
        detacher: onDetach,
        onRemove: () {
          state.losing = GameCard.losing.defaultValue;
          notifyListeners();
        },
      );
  }

  /// Variant attachments using attachMap
  void _init2variant() {
    state = GameStats();

    _cardoteka.attachMap(
      GameCard.values,
      detacher: onDetach,
      onChange: (Map<GameCard<Object>, Object?> change) {
        if (change case {GameCard.quizzesPlayed: final List<String> value}) {
          final (byDifficulty, byCategory) = _calcAll(value);
          state
            ..quizzesPlayed = value
            ..timeSpentByDifficulty = byDifficulty
            ..timeSpentByCategory = byCategory;
        }

        if (change case {GameCard.winning: final int value}) {
          state.winning = value;
        }

        if (change case {GameCard.losing: final int value}) {
          state.losing = value;
        }
        notifyListeners();
      },
      onRemove: (List<GameCard<Object>> cards) {
        if (cards.toSet().difference(GameCard.values.toSet()) case Set(
          isEmpty: true,
        )) {
          state
            ..quizzesPlayed = GameCard.quizzesPlayed.defaultValue
            ..losing = GameCard.losing.defaultValue
            ..winning = GameCard.winning.defaultValue
            ..timeSpentByDifficulty = {}
            ..timeSpentByCategory = {};
          notifyListeners();
        }
      },
      fireImmediately: true,
    );
  }

  (Map<Difficulty, Duration>, Map<Category, Duration>) _calcAll(
    List<String> quizzes,
  ) {
    // to put it mildly, there are very heavy calculations here, so the method
    // cannot be divided and everything is calculated at once
    return ({}, {});
  }
}

void main() async {
  final cardoteka = GameCardoteka(
    config: const CardotekaConfig(cards: GameCard.values),
    storage: MemoryStorage(),
  );

  QuizStatsNotifier(cardoteka);
  cardoteka.set(GameCard.losing, 1);
  cardoteka.set(GameCard.losing, 2);
  cardoteka.set(GameCard.winning, 1);
}
