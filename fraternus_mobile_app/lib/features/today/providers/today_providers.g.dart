// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Composed client-side from Guide/Challenge/Events/Profile's own providers
/// rather than a dedicated backend aggregator — reuses each tab's
/// already-migrated logic (Field Guide week/devotional resolution, current
/// challenge resolution, event visibility filtering) instead of duplicating
/// it in SQL. See the migration plan's decision notes.

@ProviderFor(todayDashboard)
const todayDashboardProvider = TodayDashboardProvider._();

/// Composed client-side from Guide/Challenge/Events/Profile's own providers
/// rather than a dedicated backend aggregator — reuses each tab's
/// already-migrated logic (Field Guide week/devotional resolution, current
/// challenge resolution, event visibility filtering) instead of duplicating
/// it in SQL. See the migration plan's decision notes.

final class TodayDashboardProvider
    extends
        $FunctionalProvider<
          AsyncValue<TodayDashboard>,
          TodayDashboard,
          FutureOr<TodayDashboard>
        >
    with $FutureModifier<TodayDashboard>, $FutureProvider<TodayDashboard> {
  /// Composed client-side from Guide/Challenge/Events/Profile's own providers
  /// rather than a dedicated backend aggregator — reuses each tab's
  /// already-migrated logic (Field Guide week/devotional resolution, current
  /// challenge resolution, event visibility filtering) instead of duplicating
  /// it in SQL. See the migration plan's decision notes.
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

String _$todayDashboardHash() => r'6b8c960384978b3ed06eb6b6de782bd3aa988505';

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
