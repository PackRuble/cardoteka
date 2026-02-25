import 'package:cardoteka/cardoteka.dart' show Cardoteka, WatcherImpl;
import 'package:cardoteka/src/core/cardoteka_async.dart';
import 'package:cardoteka/src/mixin/watcher_impl.dart';

final class CardotekaTest extends Cardoteka {
  CardotekaTest({required super.config, required super.storage});
}

final class CardotekaAsyncTest extends CardotekaAsync {
  CardotekaAsyncTest({required super.config, required super.storage});
}

final class CardotekaWatcherTest = Cardoteka with WatcherImpl, WatcherImplDebug;

final class CardotekaAsyncWatcherTest = CardotekaAsyncTest
    with WatcherImpl, WatcherImplDebug;
