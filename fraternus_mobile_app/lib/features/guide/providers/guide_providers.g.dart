// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'guide_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(guideRepository)
const guideRepositoryProvider = GuideRepositoryProvider._();

final class GuideRepositoryProvider
    extends
        $FunctionalProvider<GuideRepository, GuideRepository, GuideRepository>
    with $Provider<GuideRepository> {
  const GuideRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guideRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guideRepositoryHash();

  @$internal
  @override
  $ProviderElement<GuideRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GuideRepository create(Ref ref) {
    return guideRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GuideRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GuideRepository>(value),
    );
  }
}

String _$guideRepositoryHash() => r'2c7705346b2d51ddb2058fcd9b9f339b2d4de863';

/// The current user's household, for the Guide tab's person tabs — same
/// shape and reasoning as Challenge's `challengeHouseholdProvider`.

@ProviderFor(guideHousehold)
const guideHouseholdProvider = GuideHouseholdProvider._();

/// The current user's household, for the Guide tab's person tabs — same
/// shape and reasoning as Challenge's `challengeHouseholdProvider`.

final class GuideHouseholdProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GuideHouseholdMember>>,
          List<GuideHouseholdMember>,
          FutureOr<List<GuideHouseholdMember>>
        >
    with
        $FutureModifier<List<GuideHouseholdMember>>,
        $FutureProvider<List<GuideHouseholdMember>> {
  /// The current user's household, for the Guide tab's person tabs — same
  /// shape and reasoning as Challenge's `challengeHouseholdProvider`.
  const GuideHouseholdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guideHouseholdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guideHouseholdHash();

  @$internal
  @override
  $FutureProviderElement<List<GuideHouseholdMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<GuideHouseholdMember>> create(Ref ref) {
    return guideHousehold(ref);
  }
}

String _$guideHouseholdHash() => r'c2ce8d0e9d62ec0c4ce546fd3828300aab928446';

/// [date] must already be truncated to year/month/day — see
/// [GuideSelectedDate] — since DateTime equality (Riverpod's family-arg
/// cache key) would otherwise cache-miss on time-of-day noise.

@ProviderFor(guideWeekForDate)
const guideWeekForDateProvider = GuideWeekForDateFamily._();

/// [date] must already be truncated to year/month/day — see
/// [GuideSelectedDate] — since DateTime equality (Riverpod's family-arg
/// cache key) would otherwise cache-miss on time-of-day noise.

final class GuideWeekForDateProvider
    extends
        $FunctionalProvider<
          AsyncValue<FieldGuideWeek?>,
          FieldGuideWeek?,
          FutureOr<FieldGuideWeek?>
        >
    with $FutureModifier<FieldGuideWeek?>, $FutureProvider<FieldGuideWeek?> {
  /// [date] must already be truncated to year/month/day — see
  /// [GuideSelectedDate] — since DateTime equality (Riverpod's family-arg
  /// cache key) would otherwise cache-miss on time-of-day noise.
  const GuideWeekForDateProvider._({
    required GuideWeekForDateFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'guideWeekForDateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guideWeekForDateHash();

  @override
  String toString() {
    return r'guideWeekForDateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<FieldGuideWeek?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<FieldGuideWeek?> create(Ref ref) {
    final argument = this.argument as DateTime;
    return guideWeekForDate(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GuideWeekForDateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guideWeekForDateHash() => r'5959895595653b57fbc833b7247a3da7b53f6c15';

/// [date] must already be truncated to year/month/day — see
/// [GuideSelectedDate] — since DateTime equality (Riverpod's family-arg
/// cache key) would otherwise cache-miss on time-of-day noise.

final class GuideWeekForDateFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<FieldGuideWeek?>, DateTime> {
  const GuideWeekForDateFamily._()
    : super(
        retry: null,
        name: r'guideWeekForDateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [date] must already be truncated to year/month/day — see
  /// [GuideSelectedDate] — since DateTime equality (Riverpod's family-arg
  /// cache key) would otherwise cache-miss on time-of-day noise.

  GuideWeekForDateProvider call(DateTime date) =>
      GuideWeekForDateProvider._(argument: date, from: this);

  @override
  String toString() => r'guideWeekForDateProvider';
}

/// The single shared date for the whole Guide screen — switching it
/// applies to every household member, unlike the selected household member
/// (SelectedHouseholdMember, in shared/providers) which is a per-person
/// choice.

@ProviderFor(GuideSelectedDate)
const guideSelectedDateProvider = GuideSelectedDateProvider._();

/// The single shared date for the whole Guide screen — switching it
/// applies to every household member, unlike the selected household member
/// (SelectedHouseholdMember, in shared/providers) which is a per-person
/// choice.
final class GuideSelectedDateProvider
    extends $NotifierProvider<GuideSelectedDate, DateTime> {
  /// The single shared date for the whole Guide screen — switching it
  /// applies to every household member, unlike the selected household member
  /// (SelectedHouseholdMember, in shared/providers) which is a per-person
  /// choice.
  const GuideSelectedDateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guideSelectedDateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guideSelectedDateHash();

  @$internal
  @override
  GuideSelectedDate create() => GuideSelectedDate();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$guideSelectedDateHash() => r'5669ac4353594cdd2f16133cf10f53a7ec3a4fa9';

/// The single shared date for the whole Guide screen — switching it
/// applies to every household member, unlike the selected household member
/// (SelectedHouseholdMember, in shared/providers) which is a per-person
/// choice.

abstract class _$GuideSelectedDate extends $Notifier<DateTime> {
  DateTime build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DateTime, DateTime>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DateTime, DateTime>,
              DateTime,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Per-person completion rows for one date. Seeded once from
/// [GuideRepository], then every mutation applies an optimistic update to
/// [state] directly — never `ref.invalidate(guideWeekForDateProvider)` —
/// so the UI reflects the change on the same frame, before the network
/// write resolves. Invalidating the upstream week provider would force it
/// (and everything watching it, including this provider's own `build`)
/// through a fresh fetch, which is what caused the old implementation's
/// screen flash/scroll-reset: a real network round trip standing between
/// the tap and any visible feedback, during which `.when()`'s `loading`
/// branches collapse the content. On write failure, the optimistic change
/// is rolled back.

@ProviderFor(GuideDevotionalProgress)
const guideDevotionalProgressProvider = GuideDevotionalProgressFamily._();

/// Per-person completion rows for one date. Seeded once from
/// [GuideRepository], then every mutation applies an optimistic update to
/// [state] directly — never `ref.invalidate(guideWeekForDateProvider)` —
/// so the UI reflects the change on the same frame, before the network
/// write resolves. Invalidating the upstream week provider would force it
/// (and everything watching it, including this provider's own `build`)
/// through a fresh fetch, which is what caused the old implementation's
/// screen flash/scroll-reset: a real network round trip standing between
/// the tap and any visible feedback, during which `.when()`'s `loading`
/// branches collapse the content. On write failure, the optimistic change
/// is rolled back.
final class GuideDevotionalProgressProvider
    extends
        $AsyncNotifierProvider<
          GuideDevotionalProgress,
          Map<String, FieldGuideDailyDevotionalMember>
        > {
  /// Per-person completion rows for one date. Seeded once from
  /// [GuideRepository], then every mutation applies an optimistic update to
  /// [state] directly — never `ref.invalidate(guideWeekForDateProvider)` —
  /// so the UI reflects the change on the same frame, before the network
  /// write resolves. Invalidating the upstream week provider would force it
  /// (and everything watching it, including this provider's own `build`)
  /// through a fresh fetch, which is what caused the old implementation's
  /// screen flash/scroll-reset: a real network round trip standing between
  /// the tap and any visible feedback, during which `.when()`'s `loading`
  /// branches collapse the content. On write failure, the optimistic change
  /// is rolled back.
  const GuideDevotionalProgressProvider._({
    required GuideDevotionalProgressFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'guideDevotionalProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guideDevotionalProgressHash();

  @override
  String toString() {
    return r'guideDevotionalProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GuideDevotionalProgress create() => GuideDevotionalProgress();

  @override
  bool operator ==(Object other) {
    return other is GuideDevotionalProgressProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guideDevotionalProgressHash() =>
    r'231ade34281b2483efda91fdeb0b4eeb00c63521';

/// Per-person completion rows for one date. Seeded once from
/// [GuideRepository], then every mutation applies an optimistic update to
/// [state] directly — never `ref.invalidate(guideWeekForDateProvider)` —
/// so the UI reflects the change on the same frame, before the network
/// write resolves. Invalidating the upstream week provider would force it
/// (and everything watching it, including this provider's own `build`)
/// through a fresh fetch, which is what caused the old implementation's
/// screen flash/scroll-reset: a real network round trip standing between
/// the tap and any visible feedback, during which `.when()`'s `loading`
/// branches collapse the content. On write failure, the optimistic change
/// is rolled back.

final class GuideDevotionalProgressFamily extends $Family
    with
        $ClassFamilyOverride<
          GuideDevotionalProgress,
          AsyncValue<Map<String, FieldGuideDailyDevotionalMember>>,
          Map<String, FieldGuideDailyDevotionalMember>,
          FutureOr<Map<String, FieldGuideDailyDevotionalMember>>,
          DateTime
        > {
  const GuideDevotionalProgressFamily._()
    : super(
        retry: null,
        name: r'guideDevotionalProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Per-person completion rows for one date. Seeded once from
  /// [GuideRepository], then every mutation applies an optimistic update to
  /// [state] directly — never `ref.invalidate(guideWeekForDateProvider)` —
  /// so the UI reflects the change on the same frame, before the network
  /// write resolves. Invalidating the upstream week provider would force it
  /// (and everything watching it, including this provider's own `build`)
  /// through a fresh fetch, which is what caused the old implementation's
  /// screen flash/scroll-reset: a real network round trip standing between
  /// the tap and any visible feedback, during which `.when()`'s `loading`
  /// branches collapse the content. On write failure, the optimistic change
  /// is rolled back.

  GuideDevotionalProgressProvider call(DateTime date) =>
      GuideDevotionalProgressProvider._(argument: date, from: this);

  @override
  String toString() => r'guideDevotionalProgressProvider';
}

/// Per-person completion rows for one date. Seeded once from
/// [GuideRepository], then every mutation applies an optimistic update to
/// [state] directly — never `ref.invalidate(guideWeekForDateProvider)` —
/// so the UI reflects the change on the same frame, before the network
/// write resolves. Invalidating the upstream week provider would force it
/// (and everything watching it, including this provider's own `build`)
/// through a fresh fetch, which is what caused the old implementation's
/// screen flash/scroll-reset: a real network round trip standing between
/// the tap and any visible feedback, during which `.when()`'s `loading`
/// branches collapse the content. On write failure, the optimistic change
/// is rolled back.

abstract class _$GuideDevotionalProgress
    extends $AsyncNotifier<Map<String, FieldGuideDailyDevotionalMember>> {
  late final _$args = ref.$arg as DateTime;
  DateTime get date => _$args;

  FutureOr<Map<String, FieldGuideDailyDevotionalMember>> build(DateTime date);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, FieldGuideDailyDevotionalMember>>,
              Map<String, FieldGuideDailyDevotionalMember>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, FieldGuideDailyDevotionalMember>>,
                Map<String, FieldGuideDailyDevotionalMember>
              >,
              AsyncValue<Map<String, FieldGuideDailyDevotionalMember>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Consecutive-day streak for [personKey] as of the currently selected
/// date, NOT counting the selected date itself — the screen adds +1 live
/// when that person's selected-date row is completed.

@ProviderFor(guideBaseStreak)
const guideBaseStreakProvider = GuideBaseStreakFamily._();

/// Consecutive-day streak for [personKey] as of the currently selected
/// date, NOT counting the selected date itself — the screen adds +1 live
/// when that person's selected-date row is completed.

final class GuideBaseStreakProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Consecutive-day streak for [personKey] as of the currently selected
  /// date, NOT counting the selected date itself — the screen adds +1 live
  /// when that person's selected-date row is completed.
  const GuideBaseStreakProvider._({
    required GuideBaseStreakFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'guideBaseStreakProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guideBaseStreakHash();

  @override
  String toString() {
    return r'guideBaseStreakProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    final argument = this.argument as String;
    return guideBaseStreak(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GuideBaseStreakProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guideBaseStreakHash() => r'2a46bfa1171fbc95cd104533a92e798a7059e00b';

/// Consecutive-day streak for [personKey] as of the currently selected
/// date, NOT counting the selected date itself — the screen adds +1 live
/// when that person's selected-date row is completed.

final class GuideBaseStreakFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  const GuideBaseStreakFamily._()
    : super(
        retry: null,
        name: r'guideBaseStreakProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Consecutive-day streak for [personKey] as of the currently selected
  /// date, NOT counting the selected date itself — the screen adds +1 live
  /// when that person's selected-date row is completed.

  GuideBaseStreakProvider call(String personKey) =>
      GuideBaseStreakProvider._(argument: personKey, from: this);

  @override
  String toString() => r'guideBaseStreakProvider';
}

/// [personKey]'s saved Temperament Quiz result — null means they haven't
/// taken the quiz yet, in which case the UI renders the Find Your
/// Temperament button instead of Primary/Secondary tags. Backed by
/// `Member Temperament Result` (see docs/app_concept.md's Temperaments
/// domain section and supabase/migrations/20260821000000_temperaments.sql).

@ProviderFor(GuideTemperamentResult)
const guideTemperamentResultProvider = GuideTemperamentResultFamily._();

/// [personKey]'s saved Temperament Quiz result — null means they haven't
/// taken the quiz yet, in which case the UI renders the Find Your
/// Temperament button instead of Primary/Secondary tags. Backed by
/// `Member Temperament Result` (see docs/app_concept.md's Temperaments
/// domain section and supabase/migrations/20260821000000_temperaments.sql).
final class GuideTemperamentResultProvider
    extends $AsyncNotifierProvider<GuideTemperamentResult, TemperamentResult?> {
  /// [personKey]'s saved Temperament Quiz result — null means they haven't
  /// taken the quiz yet, in which case the UI renders the Find Your
  /// Temperament button instead of Primary/Secondary tags. Backed by
  /// `Member Temperament Result` (see docs/app_concept.md's Temperaments
  /// domain section and supabase/migrations/20260821000000_temperaments.sql).
  const GuideTemperamentResultProvider._({
    required GuideTemperamentResultFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'guideTemperamentResultProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guideTemperamentResultHash();

  @override
  String toString() {
    return r'guideTemperamentResultProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GuideTemperamentResult create() => GuideTemperamentResult();

  @override
  bool operator ==(Object other) {
    return other is GuideTemperamentResultProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guideTemperamentResultHash() =>
    r'dc20c518a3edf369f674f741ce7c35a1ab14b1f5';

/// [personKey]'s saved Temperament Quiz result — null means they haven't
/// taken the quiz yet, in which case the UI renders the Find Your
/// Temperament button instead of Primary/Secondary tags. Backed by
/// `Member Temperament Result` (see docs/app_concept.md's Temperaments
/// domain section and supabase/migrations/20260821000000_temperaments.sql).

final class GuideTemperamentResultFamily extends $Family
    with
        $ClassFamilyOverride<
          GuideTemperamentResult,
          AsyncValue<TemperamentResult?>,
          TemperamentResult?,
          FutureOr<TemperamentResult?>,
          String
        > {
  const GuideTemperamentResultFamily._()
    : super(
        retry: null,
        name: r'guideTemperamentResultProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// [personKey]'s saved Temperament Quiz result — null means they haven't
  /// taken the quiz yet, in which case the UI renders the Find Your
  /// Temperament button instead of Primary/Secondary tags. Backed by
  /// `Member Temperament Result` (see docs/app_concept.md's Temperaments
  /// domain section and supabase/migrations/20260821000000_temperaments.sql).

  GuideTemperamentResultProvider call(String personKey) =>
      GuideTemperamentResultProvider._(argument: personKey, from: this);

  @override
  String toString() => r'guideTemperamentResultProvider';
}

/// [personKey]'s saved Temperament Quiz result — null means they haven't
/// taken the quiz yet, in which case the UI renders the Find Your
/// Temperament button instead of Primary/Secondary tags. Backed by
/// `Member Temperament Result` (see docs/app_concept.md's Temperaments
/// domain section and supabase/migrations/20260821000000_temperaments.sql).

abstract class _$GuideTemperamentResult
    extends $AsyncNotifier<TemperamentResult?> {
  late final _$args = ref.$arg as String;
  String get personKey => _$args;

  FutureOr<TemperamentResult?> build(String personKey);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<TemperamentResult?>, TemperamentResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TemperamentResult?>, TemperamentResult?>,
              AsyncValue<TemperamentResult?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Per-quote favorite state for every household member on [date]'s week,
/// keyed by '$quoteId:$personKey'. Seeded from the quotes' nested
/// `field_guide_week_quotes_members` (see [FieldGuideWeekQuote.members]),
/// then optimistically updated by [toggle] — same
/// apply-immediately/rollback-on-failure shape as [GuideDevotionalProgress],
/// just without a placeholder-row step since a favorite always starts false.

@ProviderFor(GuideQuoteFavorites)
const guideQuoteFavoritesProvider = GuideQuoteFavoritesFamily._();

/// Per-quote favorite state for every household member on [date]'s week,
/// keyed by '$quoteId:$personKey'. Seeded from the quotes' nested
/// `field_guide_week_quotes_members` (see [FieldGuideWeekQuote.members]),
/// then optimistically updated by [toggle] — same
/// apply-immediately/rollback-on-failure shape as [GuideDevotionalProgress],
/// just without a placeholder-row step since a favorite always starts false.
final class GuideQuoteFavoritesProvider
    extends $AsyncNotifierProvider<GuideQuoteFavorites, Map<String, bool>> {
  /// Per-quote favorite state for every household member on [date]'s week,
  /// keyed by '$quoteId:$personKey'. Seeded from the quotes' nested
  /// `field_guide_week_quotes_members` (see [FieldGuideWeekQuote.members]),
  /// then optimistically updated by [toggle] — same
  /// apply-immediately/rollback-on-failure shape as [GuideDevotionalProgress],
  /// just without a placeholder-row step since a favorite always starts false.
  const GuideQuoteFavoritesProvider._({
    required GuideQuoteFavoritesFamily super.from,
    required DateTime super.argument,
  }) : super(
         retry: null,
         name: r'guideQuoteFavoritesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$guideQuoteFavoritesHash();

  @override
  String toString() {
    return r'guideQuoteFavoritesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GuideQuoteFavorites create() => GuideQuoteFavorites();

  @override
  bool operator ==(Object other) {
    return other is GuideQuoteFavoritesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$guideQuoteFavoritesHash() =>
    r'f1e3bb2dff00c7b8249e24088a0011f29d75a495';

/// Per-quote favorite state for every household member on [date]'s week,
/// keyed by '$quoteId:$personKey'. Seeded from the quotes' nested
/// `field_guide_week_quotes_members` (see [FieldGuideWeekQuote.members]),
/// then optimistically updated by [toggle] — same
/// apply-immediately/rollback-on-failure shape as [GuideDevotionalProgress],
/// just without a placeholder-row step since a favorite always starts false.

final class GuideQuoteFavoritesFamily extends $Family
    with
        $ClassFamilyOverride<
          GuideQuoteFavorites,
          AsyncValue<Map<String, bool>>,
          Map<String, bool>,
          FutureOr<Map<String, bool>>,
          DateTime
        > {
  const GuideQuoteFavoritesFamily._()
    : super(
        retry: null,
        name: r'guideQuoteFavoritesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Per-quote favorite state for every household member on [date]'s week,
  /// keyed by '$quoteId:$personKey'. Seeded from the quotes' nested
  /// `field_guide_week_quotes_members` (see [FieldGuideWeekQuote.members]),
  /// then optimistically updated by [toggle] — same
  /// apply-immediately/rollback-on-failure shape as [GuideDevotionalProgress],
  /// just without a placeholder-row step since a favorite always starts false.

  GuideQuoteFavoritesProvider call(DateTime date) =>
      GuideQuoteFavoritesProvider._(argument: date, from: this);

  @override
  String toString() => r'guideQuoteFavoritesProvider';
}

/// Per-quote favorite state for every household member on [date]'s week,
/// keyed by '$quoteId:$personKey'. Seeded from the quotes' nested
/// `field_guide_week_quotes_members` (see [FieldGuideWeekQuote.members]),
/// then optimistically updated by [toggle] — same
/// apply-immediately/rollback-on-failure shape as [GuideDevotionalProgress],
/// just without a placeholder-row step since a favorite always starts false.

abstract class _$GuideQuoteFavorites extends $AsyncNotifier<Map<String, bool>> {
  late final _$args = ref.$arg as DateTime;
  DateTime get date => _$args;

  FutureOr<Map<String, bool>> build(DateTime date);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref as $Ref<AsyncValue<Map<String, bool>>, Map<String, bool>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Map<String, bool>>, Map<String, bool>>,
              AsyncValue<Map<String, bool>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
