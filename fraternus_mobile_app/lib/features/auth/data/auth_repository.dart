import 'package:supabase_flutter/supabase_flutter.dart';

/// Source of the app's authentication state. Same seam as every other
/// XRepository in this codebase — screens and the router only ever depend
/// on this interface, never on `Supabase.instance.client.auth` directly.
abstract class AuthRepository {
  /// Fires on sign-in, sign-out, and token refresh — drives the router's
  /// `refreshListenable` (see app/router/app_router.dart).
  Stream<AuthState> get authStateChanges;

  Session? get currentSession;

  /// [firstName]/[lastName] are passed as signUp metadata, not written
  /// directly to any table — the `handle_new_auth_user()` Postgres trigger
  /// (supabase/migrations) reads them off `raw_user_meta_data` to populate
  /// `public.users`. Chapter selection and Member/UserMemberAssociation
  /// creation happen separately via ProfileRepository once those tables
  /// exist (see docs/adrs/002_supabase_backend_poc.md §5).
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<void> signIn({required String email, required String password});

  Future<void> signOut();

  Future<void> resetPasswordForEmail(String email);
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;

  @override
  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  @override
  Session? get currentSession => _client.auth.currentSession;

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    await _client.auth.signUp(
      email: email,
      password: password,
      data: {'first_name': firstName, 'last_name': lastName},
    );
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    await _client.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() => _client.auth.signOut();

  @override
  Future<void> resetPasswordForEmail(String email) => _client.auth.resetPasswordForEmail(email);
}
