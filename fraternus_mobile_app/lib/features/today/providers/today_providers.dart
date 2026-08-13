import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/today_dashboard_repository.dart';
import '../models/today_dashboard.dart';

part 'today_providers.g.dart';

/// Swap this provider's implementation to change where Today's data comes
/// from — nothing downstream (the dashboard provider, the screen) needs to
/// change.
@riverpod
TodayDashboardRepository todayDashboardRepository(Ref ref) {
  return const StaticTodayDashboardRepository();
}

@riverpod
Future<TodayDashboard> todayDashboard(Ref ref) {
  final repository = ref.watch(todayDashboardRepositoryProvider);
  return repository.fetchDashboard(forDate: DateTime.now());
}

/// Which household member (You/Jack/Thomas) is active in the [PersonTabs]
/// switcher. Lives in a provider rather than local widget state so it
/// composes with [todayDashboardProvider] via `ref.watch` and stays
/// reusable if a future nested route needs the same selection.
@riverpod
class TodaySelectedPerson extends _$TodaySelectedPerson {
  @override
  String build() => 'you';

  void select(String key) => state = key;
}
