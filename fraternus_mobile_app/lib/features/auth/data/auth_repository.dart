import 'package:supabase_flutter/supabase_flutter.dart';

/// Source of the app's authentication state. Same seam as every other
/// XRepository in this codebase — screens and the router only ever depend
/// on this interface, never on `Supabase.instance.client.auth` directly.
abstract class AuthRepository {
  /// Fires on sign-in, sign-out, and token refresh — drives the router's
  /// `refreshListenable` (see app/router/app_router.dart).
  Stream<AuthState> get authStateChanges;

  Session? get currentSession;

  /// Step 1 of the signup wizard (see SignUpAccountScreen): creates the
  /// underlying auth user (if one doesn't already exist) in an unconfirmed
  /// state and emails a 6-digit code to [email]. Also used to resend the
  /// code — calling it again just re-sends. No session exists yet after
  /// this; that only happens once the code is verified (see
  /// [verifyEmailOtp]), which is why first/last name (collected later in
  /// the wizard) aren't passed here — [ProfileRepository.updateProfile]
  /// fills them in afterward, once authenticated.
  Future<void> sendEmailOtp(String email);

  /// Step 2: verifying the code both confirms the email and establishes a
  /// session — ahead of the user choosing a password (see [setPassword]).
  /// The `handle_new_auth_user()` Postgres trigger (supabase/migrations)
  /// populates `public.users` at this point with blank names.
  Future<void> verifyEmailOtp({required String email, required String token});

  /// Step 3: sets a password on the session [verifyEmailOtp] established.
  /// Requires an authenticated session.
  Future<void> setPassword(String password);

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
  Future<void> sendEmailOtp(String email) async {
    await _client.auth.signInWithOtp(email: email, shouldCreateUser: true);
  }

  @override
  Future<void> verifyEmailOtp({required String email, required String token}) async {
    await _client.auth.verifyOTP(type: OtpType.email, email: email, token: token);
  }

  @override
  Future<void> setPassword(String password) async {
    await _client.auth.updateUser(UserAttributes(password: password));
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
