/// This file provides access to the original classes of the `shared_preferences` package.
/// Sometimes can be useful for debugging/testing or for use outside the system Cardoteka.
/// You must be careful and aware of what you are doing and why.
library;

export 'package:shared_preferences/shared_preferences.dart'
    show
        SharedPreferences,
        SharedPreferencesAsync,
        SharedPreferencesWithCache,
        SharedPreferencesWithCacheOptions;
// ignore: depend_on_referenced_packages
export 'package:shared_preferences_android/shared_preferences_android.dart'
    show
        AndroidSharedPreferencesStoreOptions,
        SharedPreferencesAndroid,
        SharedPreferencesAndroidBackendLibrary,
        SharedPreferencesAsyncAndroid,
        SharedPreferencesAsyncAndroidOptions;
