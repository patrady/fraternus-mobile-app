import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../app/supabase_provider.dart';
import '../data/auth_repository.dart';

part 'auth_providers.g.dart';

/// Swap this provider's implementation to change where auth comes from —
/// nothing downstream (screens, the router) needs to change.
@riverpod
AuthRepository authRepository(Ref ref) {
  return SupabaseAuthRepository(ref.watch(supabaseClientProvider));
}

/// The router watches this (via GoRouterRefreshStream) to re-run its
/// `redirect` callback whenever auth state changes.
@riverpod
Stream<AuthState> authStateChanges(Ref ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
}
