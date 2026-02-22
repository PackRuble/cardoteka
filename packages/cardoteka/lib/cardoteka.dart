// Copyright (c) 2022-2025 Ruble
//
// Use of this source code is governed by the license found in the LICENSE file.

/// The best type-safe wrapper over SharedPreferences.
///
/// Wow, it's never been safer than it is right now!
/// You can see all the available classes below.
library;

export 'src/card.dart' show Card, DataType;
export 'src/config.dart' show CardotekaConfig;
export 'src/converter.dart'
    show
        CollectionConverter,
        Converter,
        Converters,
        EnumAsIntConverter,
        EnumAsStringConverter,
        IterableConverter,
        ListConverter,
        MapConverter;
export 'src/core/cardoteka.dart' show Cardoteka;
export 'src/core/cardoteka_async.dart' show CardotekaAsync;
export 'src/core/cardoteka_core.dart' show CardotekaCore;
export 'src/core/storage/cardoteka_storage.dart'
    show CardotekaStorage, MemoryStorage;
export 'src/mixin/crud_simulation.dart' show CRUD;
export 'src/mixin/detachability.dart' show Detachability;
export 'src/mixin/watcher_impl.dart' show Detacher, ValueCallback, WatcherImpl;
export 'src/watcher.dart' show Watcher;
