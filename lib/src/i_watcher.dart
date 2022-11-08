import 'i_rkey.dart';

///
abstract class IWatcher {
  /// Get all listeners of the type `Map<RKey: actualValue>`
  Map<RKey, dynamic> getWatchers();

  /// Update the key value with the actual value.
  void actualizeValue<T>(RKey<T> rKey, T value);

  /// Add a listener for the selected [RKey] key.
  /// Provide the [onDispose] parameter if the listener can be disposed of.
  ///
  /// When you change a value in the database, the Callback [cb] will be called
  /// automatically for all listeners, providing the new value.
  /// (!) Note that it is up to you to filter the values by determining whether
  /// the current value matches the one provided.
  T listen<T>(
    RKey<T> rKey,
    Function(T value) cb, [
    void Function(void Function())? onDispose,
  ]);
}
