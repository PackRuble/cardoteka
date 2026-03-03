// Copyright (c) 2022-2025 Ruble
//
// Use of this source code is governed by the license found in the LICENSE file.

/// A generic wrapper for your storage with useful utilities!
library;

export 'src/card.dart' show Card;
export 'src/config.dart' show CardotekaConfig;
export 'src/converter.dart'
    show
        CollectionConverter,
        Converter,
        DateTimeAsIntConverter,
        DateTimeConverter,
        DurationConverter,
        EnumAsIntConverter,
        EnumAsStringConverter,
        EnumConverters,
        IterableConverter,
        ListConverter,
        MapToListConverter,
        NumAsStringConverter,
        NumConverter,
        UriConverter;
export 'src/core/cardoteka.dart' show Cardoteka;
export 'src/core/cardoteka_async.dart' show CardotekaAsync;
export 'src/core/cardoteka_core.dart' show CardotekaCore;
export 'src/core/storage/cardoteka_storage.dart'
    show CardotekaStorage, MemoryStorage;
export 'src/data_type.dart' show DataType;
export 'src/extensions/future_ext.dart' show FutureSync;
export 'src/mixin/crud_simulation.dart' show CRUD;
export 'src/mixin/detachability.dart' show Detachability;
export 'src/mixin/watcher_impl.dart'
    show ChangeValueCallback, Detacher, RemoveRecordCallback, WatcherImpl;
export 'src/watcher.dart' show Watcher;
