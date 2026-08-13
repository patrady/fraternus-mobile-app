// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Swap this provider's implementation to change where Today's data comes
/// from — nothing downstream (the dashboard provider, the screen) needs to
/// change.

@ProviderFor(todayDashboardRepository)
const todayDashboardRepositoryProvider = TodayDashboardRepositoryProvider._();

/// Swap this provider's implementation to change where Today's data comes
/// from — nothing downstream (the dashboard provider, the screen) needs to
/// change.

final class TodayDashboardRepositoryProvider
    extends
        $FunctionalProvider<
          TodayDashboardRepository,
          TodayDashboardRepository,
          TodayDashboardRepository
        >
    with $Provider<TodayDashboardRepository> {
  /// Swap this provider's implementation to change where Today's data comes
  /// from — nothing downstream (the dashboard provider, the screen) needs to
  /// change.
  const TodayDashboardRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayDashboardRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayDashboardRepositoryHash();

  @$internal
  @override
  $ProviderElement<TodayDashboardRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  TodayDashboardRepository create(Ref ref) {
    return todayDashboardRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TodayDashboardRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TodayDashboardRepository>(value),
    );
  }
}

String _$todayDashboardRepositoryHash() =>
    r'9ddff3de39fa108e2864ff5d2b1b1d738bd46767';

@ProviderFor(todayDashboard)
const todayDashboardProvider = TodayDashboardProvider._();

final class TodayDashboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<TodayDashboard>,
          TodayDashboard,
          FutureOr<TodayDashboard>
        >
    with $FutureModifier<TodayDashboard>, $FutureProvider<TodayDashboard> {
  const TodayDashboardProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todayDashboardProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todayDashboardHash();

  @$internal
  @override
  $FutureProviderElement<TodayDashboard> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<TodayDashboard> create(Ref ref) {
    return todayDashboard(ref);
  }
}

String _$todayDashboardHash() => r'3bfc1bd6a3938b5af1730bc56ad8cfd65e3767ee';

/// Which household member (You/Jack/Thomas) is active in the [PersonTabs]
/// switcher. Lives in a provider rather than local widget state so it
/// composes with [todayDashboardProvider] via `ref.watch` and stays
/// reusable if a future nested route needs the same selection.

@ProviderFor(TodaySelectedPerson)
const todaySelectedPersonProvider = TodaySelectedPersonProvider._();

/// Which household member (You/Jack/Thomas) is active in the [PersonTabs]
/// switcher. Lives in a provider rather than local widget state so it
/// composes with [todayDashboardProvider] via `ref.watch` and stays
/// reusable if a future nested route needs the same selection.
final class TodaySelectedPersonProvider
    extends $NotifierProvider<TodaySelectedPerson, String> {
  /// Which household member (You/Jack/Thomas) is active in the [PersonTabs]
  /// switcher. Lives in a provider rather than local widget state so it
  /// composes with [todayDashboardProvider] via `ref.watch` and stays
  /// reusable if a future nested route needs the same selection.
  const TodaySelectedPersonProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'todaySelectedPersonProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$todaySelectedPersonHash();

  @$internal
  @override
  TodaySelectedPerson create() => TodaySelectedPerson();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$todaySelectedPersonHash() =>
    r'b9af8325b92fa6f8da0c4df4549619abff23bd50';

/// Which household member (You/Jack/Thomas) is active in the [PersonTabs]
/// switcher. Lives in a provider rather than local widget state so it
/// composes with [todayDashboardProvider] via `ref.watch` and stays
/// reusable if a future nested route needs the same selection.

abstract class _$TodaySelectedPerson extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
