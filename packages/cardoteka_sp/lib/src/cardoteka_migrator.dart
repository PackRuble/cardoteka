import 'package:cardoteka/cardoteka.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

import 'cardoteka_sp_async.dart';

/// {@template cardoteka.HandlerEntryV2}
/// [HandlerEntryV2] represents a record resulting from the execution of a data migration handler.
/// Her parameters:
/// - [key] a new key associated with a value that will be stored in storage.
/// - [value] a new value associated with a key that will be stored in storage.
/// If the [HandlerEntryV2.value] is null, no write to the new storage will occur.
/// - [removeOld] allows you to delete an entry from the old storage.
/// - [ignore] completely ignores this entry.
/// {@endtemplate}
typedef HandlerEntryV2 = (
  String key,
  Object? value, {
  bool removeOld,
  bool ignore,
});

/// A special class for data migration.
final class CardotekaMigrator {
  const CardotekaMigrator._();

  static HandlerEntryV2 _migrateV2Handler(
    String key,
    Object? value,
  ) =>
      (key, value, removeOld: true, ignore: false);

  @protected
  @visibleForTesting
  static const didMigrateV2key = '_cardoteka_package_did_migrate_v2';

  /// ## Migrating [toV2] and using [toV2Handler]
  ///
  /// Migration version 2 must be carried out if:
  /// - you previously used `cardoteka` package version `1.*.*`;
  /// - you previously used `shared_preferences` version `2.3.0` and lower;
  ///
  /// Then do the following and it will automatically migrate your data:
  /// ```dart
  /// await CardotekaMigrator.migrate();
  /// // and then the usual actions
  /// await Cardoteka.init();
  /// ```
  ///
  /// By default, all your entries from the old version of the storage
  /// will be moved to the new one (old storage will be cleared).
  ///
  /// If you need more control over the process, you can define your own handler
  /// for each entry:
  /// ```dart
  /// await CardotekaMigrator.migrate(
  ///   toV2Handler: (key, value) => (key, value, removeOld: false, ignore: false),
  /// );
  /// ```
  ///
  /// If you don't need migration, then either don't call this method, or do this:
  /// ```dart
  /// await CardotekaMigrator.migrate(toV2Handler: null);
  /// ```
  ///
  /// The result [HandlerEntryV2] of executing [toV2Handler] shows what should
  /// be done with the given entry.
  /// {@macro cardoteka.HandlerEntryV2}
  ///
  /// *Let's deal with some special cases*. Suppose you needed:
  /// - `fcm_vapid_key` save in new storage and leave in old storage
  /// - `platform_available_memory_mb` ignore for new storage and leave in old storage
  /// - `theme_mode_index` change name to 'user_settings.themeModeApp' and
  /// change value from `1` to `light` and delete from old storage
  ///
  /// Moreover, we would like to use the `user_settings.themeModeApp` key later
  /// on as `Card` with `Cardoteka`. To do this, add the name specified
  /// in `CardotekaConfig` and the dot `.` to the key in the prefix.
  ///
  /// And if your configuration looks like this:
  /// ```dart
  /// const config = CardotekaConfig(
  ///   name: 'user_settings',
  ///   cards: [/* .., StorageCard.themeModeApp .., */],
  /// );
  /// ```
  ///
  /// In addition to this, you have used Cardoteka before and there are also
  /// keys (cards) stored there that will simply be move to new storage:
  /// - `user_settings.isPremium`
  /// - `user_settings.userName`
  ///
  /// Everything in general can be done like this:
  /// ```dart
  /// await CardotekaMigrator.migrate(
  ///   toV2Handler: (key, value) => switch (key) {
  ///     'fsm_vapid_key' => (key, value, removeOld: false, ignore: false),
  ///     'platform_available_memory_mb' => (key, value, removeOld: false, ignore: true),
  ///     'theme_mode_index' => (
  ///         '${config.name}.themeModeApp',
  ///         switch (value) {
  ///           1 => ThemeMode.light,
  ///           2 => ThemeMode.dark,
  ///           _ => ThemeMode.system,
  ///         }
  ///             .name,
  ///         removeOld: true,
  ///         ignore: false,
  ///       ),
  ///     // for all other keys
  ///     _ => (key, value, removeOld: true, ignore: false),
  ///   },
  /// );
  ///
  /// // It was before migration in old storage:
  /// // {
  /// //   'fsm_vapid_key': 'BKagOny0KF_2pCJQ3mmoL0ewzQ8rZu',
  /// //   'platform_available_memory_mb': 2119.3,
  /// //   'theme_mode_index': 1,
  /// // };
  /// // and at the same time in new storage:
  /// // {
  /// //   'user_settings.isPremium': true,
  /// //   'user_settings.userName': 'Ivan',
  /// // };
  /// //
  /// //
  /// // Now after migration in old storage:
  /// // {
  /// //   'fsm_vapid_key': 'BKagOny0KF_2pCJQ3mmoL0ewzQ8rZu',
  /// //   'platform_available_memory_mb': 2119.3,
  /// // };
  /// // and in new storage:
  /// // {
  /// //   'fsm_vapid_key': 'BKagOny0KF_2pCJQ3mmoL0ewzQ8rZu',
  /// //   'user_settings.themeModeApp': 'light',
  /// //   'user_settings.isPremium': true,
  /// //   'user_settings.userName': 'Ivan',
  /// //   '_cardoteka_package_did_migrate_v2': true,
  /// // };
  /// ```
  ///
  /// Note! Depending on the platform, the old and new storage may overlap.
  /// This method potentially takes this into account.
  ///
  /// The migration will result in an entry with the [didMigrateV2key] key
  /// in storage about the status of the current migration.
  static Future<void> migrate({
    HandlerEntryV2 Function(String key, Object? value)? toV2Handler =
        _migrateV2Handler,
  }) async {
    if (toV2Handler != null) {
      final spNew = CardotekaAsync(
        storage: CardotekaSpAsync(const StorageConfig()),
        // configuration will not be used in operation
        config: const CardotekaConfig(prefix: '', cards: []),
      );

      bool? didMigrate =
          // ignore: invalid_use_of_protected_member, invalid_use_of_internal_member
          await spNew.getObjectFromStorage(didMigrateV2key, DataType.bool)
              as bool?;
      didMigrate ??= false;

      if (!didMigrate) {
        final spOld = await SharedPreferences.getInstance();

        for (String key in spOld.getKeys()) {
          Object? value = spOld.get(key);

          final HandlerEntryV2 result = toV2Handler.call(key, value);

          if (result.removeOld) await spOld.remove(key);
          if (result.ignore) continue;

          key = result.$1;
          value = result.$2;
          // ignore: invalid_use_of_protected_member
          if (value != null) await spNew.setObjectToStorage(key, value);
        }
        didMigrate = true;
        // ignore: invalid_use_of_protected_member
        await spNew.setObjectToStorage(didMigrateV2key, didMigrate);
      }
    }
  }
}
