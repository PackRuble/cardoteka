import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;

/// Abstract class for migrations.
abstract class CardotekaMigrator {
  /// Private.
  CardotekaMigrator._();

  /// Returns true if the migration was successful.
  static Future<bool> migrateToV2({
    required Future<bool> Function<V extends Object>(String key, V value)
        saveMethod,
  }) async {
    bool? isSuccess;
    try {
      final sp = await SharedPreferences.getInstance();

      for (final key in sp.getKeys()) {
        final value = sp.get(key);
        if (value != null) {
          // todo(18.01.2025): продумать, какой результат мы хотим видеть
          await sp.remove(key);
          await saveMethod(key, value);
        }
      }
      isSuccess = true;
    } finally {
      isSuccess ??= false;
    }
    return isSuccess;
  }
}
