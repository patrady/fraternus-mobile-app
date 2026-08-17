// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supabase_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The single [SupabaseClient] instance, initialized once in `main.dart`
/// before `runApp`. Every `SupabaseXRepository` depends on this rather than
/// reaching for `Supabase.instance.client` directly, so tests can override
/// it with a fake/mock client via `ProviderScope(overrides: [...])`.

@ProviderFor(supabaseClient)
const supabaseClientProvider = SupabaseClientProvider._();

/// The single [SupabaseClient] instance, initialized once in `main.dart`
/// before `runApp`. Every `SupabaseXRepository` depends on this rather than
/// reaching for `Supabase.instance.client` directly, so tests can override
/// it with a fake/mock client via `ProviderScope(overrides: [...])`.

final class SupabaseClientProvider
    extends $FunctionalProvider<SupabaseClient, SupabaseClient, SupabaseClient>
    with $Provider<SupabaseClient> {
  /// The single [SupabaseClient] instance, initialized once in `main.dart`
  /// before `runApp`. Every `SupabaseXRepository` depends on this rather than
  /// reaching for `Supabase.instance.client` directly, so tests can override
  /// it with a fake/mock client via `ProviderScope(overrides: [...])`.
  const SupabaseClientProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supabaseClientProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supabaseClientHash();

  @$internal
  @override
  $ProviderElement<SupabaseClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SupabaseClient create(Ref ref) {
    return supabaseClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SupabaseClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SupabaseClient>(value),
    );
  }
}

String _$supabaseClientHash() => r'834a58d6ae4b94e36f4e04a10d8a7684b929310e';
