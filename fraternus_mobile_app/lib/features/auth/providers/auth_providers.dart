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

/// True from the moment SignUpRoleScreen's Continue button navigates into
/// SignUpAccountScreen until that wizard is explicitly left (back to role
/// selection, or "Let's Get Started" on the finished step). The router's
/// redirect (see app/router/app_router.dart) reads this to keep the wizard
/// on screen even after its OTP-verify step establishes a session partway
/// through — without it, becoming signed-in mid-wizard would immediately
/// redirect away from it.
///
/// `keepAlive: true` — every call site only ever `ref.read`s this (the
/// router's redirect closure and the two screens that flip it), never
/// `ref.watch`es it, so nothing would otherwise hold it alive. Left at the
/// default autoDispose, riverpod tears it down (back to `false`) the
/// moment nothing's listening, which is immediately after every read —
/// the flag would never actually stick.
@Riverpod(keepAlive: true)
class SignUpWizardActive extends _$SignUpWizardActive {
  @override
  bool build() => false;

  void set(bool value) => state = value;
}
