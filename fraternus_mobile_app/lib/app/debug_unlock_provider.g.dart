// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debug_unlock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(DebugMenuUnlocked)
const debugMenuUnlockedProvider = DebugMenuUnlockedProvider._();

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
final class DebugMenuUnlockedProvider
    extends $NotifierProvider<DebugMenuUnlocked, bool> {
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
  const DebugMenuUnlockedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'debugMenuUnlockedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$debugMenuUnlockedHash();

  @$internal
  @override
  DebugMenuUnlocked create() => DebugMenuUnlocked();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$debugMenuUnlockedHash() => r'26ada6bd11199061206ad028706c77476ba8dcac';

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

abstract class _$DebugMenuUnlocked extends $Notifier<bool> {
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
