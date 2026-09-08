// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Swap this provider's implementation to change where the version-lockout
/// check's data comes from — nothing downstream needs to change.

@ProviderFor(appVersionRepository)
const appVersionRepositoryProvider = AppVersionRepositoryProvider._();

/// Swap this provider's implementation to change where the version-lockout
/// check's data comes from — nothing downstream needs to change.

final class AppVersionRepositoryProvider
    extends
        $FunctionalProvider<
          AppVersionRepository,
          AppVersionRepository,
          AppVersionRepository
        >
    with $Provider<AppVersionRepository> {
  /// Swap this provider's implementation to change where the version-lockout
  /// check's data comes from — nothing downstream needs to change.
  const AppVersionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionRepositoryHash();

  @$internal
  @override
  $ProviderElement<AppVersionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppVersionRepository create(Ref ref) {
    return appVersionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppVersionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppVersionRepository>(value),
    );
  }
}

String _$appVersionRepositoryHash() =>
    r'f26be7a09320e87364e74a8ce4e54fee1fc5bb1c';

/// The boot-time check's result, resolved once in `main.dart` (via
/// [resolveAppVersionStatus]) before `runApp` and injected with
/// `.overrideWithValue` — mirrors sharedPreferencesProvider. The router's
/// `redirect` can't itself `await`, so this needs to already be resolved
/// and readable synchronously (`ref.read`) by the time it first runs.

@ProviderFor(appVersionStatus)
const appVersionStatusProvider = AppVersionStatusProvider._();

/// The boot-time check's result, resolved once in `main.dart` (via
/// [resolveAppVersionStatus]) before `runApp` and injected with
/// `.overrideWithValue` — mirrors sharedPreferencesProvider. The router's
/// `redirect` can't itself `await`, so this needs to already be resolved
/// and readable synchronously (`ref.read`) by the time it first runs.

final class AppVersionStatusProvider
    extends
        $FunctionalProvider<
          AppVersionStatus,
          AppVersionStatus,
          AppVersionStatus
        >
    with $Provider<AppVersionStatus> {
  /// The boot-time check's result, resolved once in `main.dart` (via
  /// [resolveAppVersionStatus]) before `runApp` and injected with
  /// `.overrideWithValue` — mirrors sharedPreferencesProvider. The router's
  /// `redirect` can't itself `await`, so this needs to already be resolved
  /// and readable synchronously (`ref.read`) by the time it first runs.
  const AppVersionStatusProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionStatusProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionStatusHash();

  @$internal
  @override
  $ProviderElement<AppVersionStatus> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AppVersionStatus create(Ref ref) {
    return appVersionStatus(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppVersionStatus value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppVersionStatus>(value),
    );
  }
}

String _$appVersionStatusHash() => r'26ff3f877d3ce787fae51d9716cf735ec27519da';
