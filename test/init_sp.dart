import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';

// [[shared_preferences] Remove legacy testing section from README · Issue #153108 · flutter/flutter](https://github.com/flutter/flutter/issues/153108#issuecomment-2278456305)
void initSP() {
  SharedPreferencesAsyncPlatform.instance =
      InMemorySharedPreferencesAsync.empty();
}
