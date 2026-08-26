// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The whole app's [GoRouter], as a provider (not a bare top-level
/// constant) so it can depend on [authStateChangesProvider] for the auth
/// gate below.

@ProviderFor(appRouter)
const appRouterProvider = AppRouterProvider._();

/// The whole app's [GoRouter], as a provider (not a bare top-level
/// constant) so it can depend on [authStateChangesProvider] for the auth
/// gate below.

final class AppRouterProvider extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The whole app's [GoRouter], as a provider (not a bare top-level
  /// constant) so it can depend on [authStateChangesProvider] for the auth
  /// gate below.
  const AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) => $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(origin: this, providerOverride: $SyncValueProvider<GoRouter>(value));
  }
}

String _$appRouterHash() => r'c24544743b2829a57b67fe9229b237cc84683f1f';
