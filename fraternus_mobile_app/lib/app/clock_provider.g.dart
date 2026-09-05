// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Debug-only override for "now" — null means "use the real wall clock".
/// Set from the Debug tab (see features/debug/) to preview how Today,
/// Challenges, Events, and Field Guide behave on a different date without
/// changing the device clock. Every provider/widget in those features that
/// previously called `DateTime.now()` directly reads [nowProvider] instead,
/// so overriding this one value propagates everywhere at once.
///
/// This only fakes the client's notion of "now" — it can't fake Postgres'
/// own `now()` (e.g. `toggle_challenge_rep`'s `completed_date`), so a write
/// made under an overridden date still lands with the real wall-clock
/// timestamp once it round-trips through the backend.

@ProviderFor(AppClock)
const appClockProvider = AppClockProvider._();

/// Debug-only override for "now" — null means "use the real wall clock".
/// Set from the Debug tab (see features/debug/) to preview how Today,
/// Challenges, Events, and Field Guide behave on a different date without
/// changing the device clock. Every provider/widget in those features that
/// previously called `DateTime.now()` directly reads [nowProvider] instead,
/// so overriding this one value propagates everywhere at once.
///
/// This only fakes the client's notion of "now" — it can't fake Postgres'
/// own `now()` (e.g. `toggle_challenge_rep`'s `completed_date`), so a write
/// made under an overridden date still lands with the real wall-clock
/// timestamp once it round-trips through the backend.
final class AppClockProvider extends $NotifierProvider<AppClock, DateTime?> {
  /// Debug-only override for "now" — null means "use the real wall clock".
  /// Set from the Debug tab (see features/debug/) to preview how Today,
  /// Challenges, Events, and Field Guide behave on a different date without
  /// changing the device clock. Every provider/widget in those features that
  /// previously called `DateTime.now()` directly reads [nowProvider] instead,
  /// so overriding this one value propagates everywhere at once.
  ///
  /// This only fakes the client's notion of "now" — it can't fake Postgres'
  /// own `now()` (e.g. `toggle_challenge_rep`'s `completed_date`), so a write
  /// made under an overridden date still lands with the real wall-clock
  /// timestamp once it round-trips through the backend.
  const AppClockProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appClockProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appClockHash();

  @$internal
  @override
  AppClock create() => AppClock();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime?>(value),
    );
  }
}

String _$appClockHash() => r'eeb80f8ebf2a30b0dfad334fd2235f3b03a709a8';

/// Debug-only override for "now" — null means "use the real wall clock".
/// Set from the Debug tab (see features/debug/) to preview how Today,
/// Challenges, Events, and Field Guide behave on a different date without
/// changing the device clock. Every provider/widget in those features that
/// previously called `DateTime.now()` directly reads [nowProvider] instead,
/// so overriding this one value propagates everywhere at once.
///
/// This only fakes the client's notion of "now" — it can't fake Postgres'
/// own `now()` (e.g. `toggle_challenge_rep`'s `completed_date`), so a write
/// made under an overridden date still lands with the real wall-clock
/// timestamp once it round-trips through the backend.

abstract class _$AppClock extends $Notifier<DateTime?> {
  DateTime? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DateTime?, DateTime?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime?, DateTime?>,
              DateTime?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// The effective "now" every date-sensitive provider/widget should read
/// instead of calling `DateTime.now()` directly.

@ProviderFor(now)
const nowProvider = NowProvider._();

/// The effective "now" every date-sensitive provider/widget should read
/// instead of calling `DateTime.now()` directly.

final class NowProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  /// The effective "now" every date-sensitive provider/widget should read
  /// instead of calling `DateTime.now()` directly.
  const NowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'nowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$nowHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return now(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$nowHash() => r'362ad3d35a99a95d6718dcd5fb575667a18a2de4';
