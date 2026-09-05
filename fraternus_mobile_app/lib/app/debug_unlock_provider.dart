import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'shared_preferences_provider.dart';

part 'debug_unlock_provider.g.dart';

const _prefsKey = 'debug_menu_unlocked';

/// Whether the Debug tab (see clock_provider.dart) is currently visible in
/// the bottom tab bar — see [TodayHeader]'s weekday-label tap handler for
/// the actual unlock gesture (10 taps within 10 seconds, same gesture
/// toggles it back off). Even when this is true, [AppShell] still only
/// shows the tab when `kDebugMode`, and app_router.dart's redirect refuses
/// to navigate to the route at all otherwise — this alone never exposes it
/// in a release build.
///
/// Persisted on-device (see shared_preferences_provider.dart) rather than
/// in-memory, so a tester who's unlocked it doesn't have to redo the
/// gesture after every cold start.
@riverpod
class DebugMenuUnlocked extends _$DebugMenuUnlocked {
  @override
  bool build() =>
      ref.watch(sharedPreferencesProvider).getBool(_prefsKey) ?? false;

  void toggle() {
    final next = !state;
    state = next;
    ref.read(sharedPreferencesProvider).setBool(_prefsKey, next);
  }
}
