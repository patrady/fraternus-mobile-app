// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Swap this provider's implementation to change where auth comes from —
/// nothing downstream (screens, the router) needs to change.

@ProviderFor(authRepository)
const authRepositoryProvider = AuthRepositoryProvider._();

/// Swap this provider's implementation to change where auth comes from —
/// nothing downstream (screens, the router) needs to change.

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  /// Swap this provider's implementation to change where auth comes from —
  /// nothing downstream (screens, the router) needs to change.
  const AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'49b4bef701d64bd4f2cc06473188073a4786160f';

/// The router watches this (via GoRouterRefreshStream) to re-run its
/// `redirect` callback whenever auth state changes.

@ProviderFor(authStateChanges)
const authStateChangesProvider = AuthStateChangesProvider._();

/// The router watches this (via GoRouterRefreshStream) to re-run its
/// `redirect` callback whenever auth state changes.

final class AuthStateChangesProvider
    extends
        $FunctionalProvider<AsyncValue<AuthState>, AuthState, Stream<AuthState>>
    with $FutureModifier<AuthState>, $StreamProvider<AuthState> {
  /// The router watches this (via GoRouterRefreshStream) to re-run its
  /// `redirect` callback whenever auth state changes.
  const AuthStateChangesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateChangesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateChangesHash();

  @$internal
  @override
  $StreamProviderElement<AuthState> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthState> create(Ref ref) {
    return authStateChanges(ref);
  }
}

String _$authStateChangesHash() => r'7f8e913e2b53b753e4ba8a1db98023605316931a';

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

@ProviderFor(SignUpWizardActive)
const signUpWizardActiveProvider = SignUpWizardActiveProvider._();

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
final class SignUpWizardActiveProvider
    extends $NotifierProvider<SignUpWizardActive, bool> {
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
  const SignUpWizardActiveProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpWizardActiveProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpWizardActiveHash();

  @$internal
  @override
  SignUpWizardActive create() => SignUpWizardActive();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$signUpWizardActiveHash() =>
    r'aefcaae79478aba7a367ee7e774541752ecd47ce';

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

abstract class _$SignUpWizardActive extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
