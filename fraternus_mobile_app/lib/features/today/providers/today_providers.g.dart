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

String _$todayDashboardHash() => r'85e2b959604d47691c9621c6bd395142b079b546';
