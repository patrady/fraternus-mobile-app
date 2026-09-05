import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'shared_preferences_provider.g.dart';

/// The single [SharedPreferences] instance, loaded once in `main.dart`
/// before `runApp` (mirrors supabase_provider.dart's `SupabaseClient`
/// pattern) — every provider that needs simple on-device persistence (see
/// debug_unlock_provider.dart) depends on this rather than calling
/// `SharedPreferences.getInstance()` itself, so it can be overridden with a
/// mock instance in tests.
@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden — see main.dart',
  );
}
