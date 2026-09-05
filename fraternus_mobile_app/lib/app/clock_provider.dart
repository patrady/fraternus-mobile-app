import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clock_provider.g.dart';

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
@riverpod
class AppClock extends _$AppClock {
  @override
  DateTime? build() => null;

  void overrideNow(DateTime date) => state = date;

  void reset() => state = null;
}

/// The effective "now" every date-sensitive provider/widget should read
/// instead of calling `DateTime.now()` directly.
@riverpod
DateTime now(Ref ref) => ref.watch(appClockProvider) ?? DateTime.now();
