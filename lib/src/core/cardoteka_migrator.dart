import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

import '../card.dart';
import 'cardoteka_core.dart';

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

/// Extension for data migration.
extension CardotekaMigrator on CardotekaCore {
  static HandlerEntryV2 _migrateV2Handler(
    String key,
    Object? value,
  ) =>
      (key, value, removeOld: true, ignore: false);

  static const _didMigrateV2key = '_cardoteka_package_did_migrate_v2';

  /// ## Migrating [toV2] and using [toV2Handler]
  ///
  /// Migration version 2 must be carried out if:
  /// - you previously used `cardoteka` package version `1.*.*`;
  /// - you previously used `shared_preferences` version `2.3.0` and lower;
  ///
  /// To do this, call the `migrate` method on any of your `CardotekaCore` heir instances:
  /// ```dart
  /// final cardoteka = CardotekaAsync(config: config);
  /// await cardoteka.migrate();
  /// ```
  /// By default, all your entries from the old version of the storage
  /// will be moved to the new one (old storage will be cleared).
  ///
  /// If you need more control over the process, you can define your own handler
  /// for each entry:
  /// ```dart
  /// await cardoteka.migrate(
  ///   toV2Handler: (key, value) =>
  ///       (key, value, removeOld: false, ignore: false),
  /// );
  /// ```
  ///
  /// If you don't need migration, then either don't call this method, or do this:
  /// ```dart
  /// await cardoteka.migrate(toV2Handler: null);
  /// ```
  ///
  /// The result [HandlerEntryV2] of executing [toV2Handler] shows what should
  /// be done with the given entry.
  /// {@macro cardoteka.HandlerEntryV2}
  ///
  /// Let's deal with some special cases. Suppose you needed
  /// to store a key `fcm_vapid_key` in old storage, and you needed
  /// to ignore a key `platform_id` and not move it to new storage,
  /// and one more key `theme_mode_index` must be renamed and its value changed
  /// to a different value.
  /// Then, it can be done like this:
  /// ```dart
  /// await cardoteka.migrate(
  ///   toV2Handler: (key, value) => switch (key) {
  ///     'fsm_vapid_key' => (key, value, removeOld: false, ignore: false),
  ///     'platform_id' => (key, value, removeOld: false, ignore: true),
  ///     'theme_mode_index' => (
  ///         'theme_mode',
  ///         switch (value) {
  ///           1 => ThemeMode.light,
  ///           2 => ThemeMode.dark,
  ///           _ => ThemeMode.system,
  ///         }
  ///             .name,
  ///         removeOld: false,
  ///         ignore: false,
  ///       ),
  ///     _ => (key, value, removeOld: true, ignore: false),
  ///   },
  /// );
  ///
  /// // or do so, although in the current case the first spelling is semantically easier:
  /// await cardoteka.migrate(
  ///   toV2Handler: (key, value) => (
  ///     switch (key) { 'theme_mode_index' => 'theme_mode', _ => key },
  ///     switch (key) {
  ///       'theme_mode_index' => switch (value) {
  ///           1 => ThemeMode.light,
  ///           2 => ThemeMode.dark,
  ///           _ => ThemeMode.system,
  ///         }
  ///             .name,
  ///       _ => value,
  ///     },
  ///     removeOld: switch (key) { 'fsm_vapid_key' => false, _ => true },
  ///     ignore: switch (key) { 'platform_id' => true, _ => false },
  ///   ),
  /// );
  /// // It was before migration in old storage:
  /// // {
  /// //   'fsm_vapid_key': 'BKagOny0KF_2pCJQ3mmoL0ewzQ8rZu',
  /// //   'platform_id': 383283478123,
  /// //   'theme_mode_index': 1,
  /// // };
  /// //
  /// // Now after migration in old storage:
  /// // {
  /// //   'fsm_vapid_key': 'BKagOny0KF_2pCJQ3mmoL0ewzQ8rZu',
  /// //   'platform_id': 383283478123,
  /// //   'theme_mode_index': 1,
  /// // };
  /// // And in new storage:
  /// // {
  /// //   'fsm_vapid_key': 'BKagOny0KF_2pCJQ3mmoL0ewzQ8rZu',
  /// //   'theme_mode': 'light',
  /// // };
  /// ```
  ///
  /// Note! Depending on the platform, the old and new storage may overlap.
  /// This method potentially takes this into account.
  ///
  /// The migration will result in an entry with the [_didMigrateV2key] key
  /// in storage about the status of the current migration.
  Future<void> migrate({
    HandlerEntryV2 Function(String key, Object? value)? toV2Handler =
        _migrateV2Handler,
  }) async {
    if (toV2Handler != null) {
      bool? didMigrate =
          await getObjectFromStorage(_didMigrateV2key, DataType.bool) as bool?;
      didMigrate ??= false;

      if (!didMigrate) {
        // todo(18.01.2025): продумать, какой результат мы хотим видеть
        bool? isSuccess;
        try {
          final sp = await SharedPreferences.getInstance();

          for (String key in sp.getKeys()) {
            Object? value = sp.get(key);

            final HandlerEntryV2 result = toV2Handler.call(key, value);
            if (result.ignore) continue;
            if (result.removeOld) await sp.remove(key); // delete using old key

            key = result.$1;
            value = result.$2;
            if (value != null) await setObjectToStorage(key, value);
          }
          isSuccess = true;
        } finally {
          isSuccess ??= false;
        }
        await setObjectToStorage(_didMigrateV2key, isSuccess);
      }
    }
  }
}
