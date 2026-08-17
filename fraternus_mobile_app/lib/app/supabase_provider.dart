import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'supabase_provider.g.dart';

/// The single [SupabaseClient] instance, initialized once in `main.dart`
/// before `runApp`. Every `SupabaseXRepository` depends on this rather than
/// reaching for `Supabase.instance.client` directly, so tests can override
/// it with a fake/mock client via `ProviderScope(overrides: [...])`.
@riverpod
SupabaseClient supabaseClient(Ref ref) {
  return Supabase.instance.client;
}
