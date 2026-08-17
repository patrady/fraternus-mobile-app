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
