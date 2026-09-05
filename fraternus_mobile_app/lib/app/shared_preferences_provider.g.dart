// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_preferences_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single [SharedPreferences] instance, loaded once in `main.dart`
/// before `runApp` (mirrors supabase_provider.dart's `SupabaseClient`
/// pattern) — every provider that needs simple on-device persistence (see
/// debug_unlock_provider.dart) depends on this rather than calling
/// `SharedPreferences.getInstance()` itself, so it can be overridden with a
/// mock instance in tests.

@ProviderFor(sharedPreferences)
const sharedPreferencesProvider = SharedPreferencesProvider._();

/// The single [SharedPreferences] instance, loaded once in `main.dart`
/// before `runApp` (mirrors supabase_provider.dart's `SupabaseClient`
/// pattern) — every provider that needs simple on-device persistence (see
/// debug_unlock_provider.dart) depends on this rather than calling
/// `SharedPreferences.getInstance()` itself, so it can be overridden with a
/// mock instance in tests.

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          SharedPreferences,
          SharedPreferences,
          SharedPreferences
        >
    with $Provider<SharedPreferences> {
  /// The single [SharedPreferences] instance, loaded once in `main.dart`
  /// before `runApp` (mirrors supabase_provider.dart's `SupabaseClient`
  /// pattern) — every provider that needs simple on-device persistence (see
  /// debug_unlock_provider.dart) depends on this rather than calling
  /// `SharedPreferences.getInstance()` itself, so it can be overridden with a
  /// mock instance in tests.
  const SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'72a10e491f27d756c7bc9768677d82e3cd8774ef';
