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

String _$guideWeekForDateHash() => r'683d96956763eab768e6931a4fc0022b5a1d581d';

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
/// applies to every household member, unlike [GuideSelectedPerson] which
/// stays independent per feature (matching TodaySelectedPerson/
/// ChallengeSelectedPerson).

@ProviderFor(GuideSelectedDate)
const guideSelectedDateProvider = GuideSelectedDateProvider._();

/// The single shared date for the whole Guide screen — switching it
/// applies to every household member, unlike [GuideSelectedPerson] which
/// stays independent per feature (matching TodaySelectedPerson/
/// ChallengeSelectedPerson).
final class GuideSelectedDateProvider
    extends $NotifierProvider<GuideSelectedDate, DateTime> {
  /// The single shared date for the whole Guide screen — switching it
  /// applies to every household member, unlike [GuideSelectedPerson] which
  /// stays independent per feature (matching TodaySelectedPerson/
  /// ChallengeSelectedPerson).
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

String _$guideSelectedDateHash() => r'5e68e9b3df691178661a86ed189a582977ba0089';

/// The single shared date for the whole Guide screen — switching it
/// applies to every household member, unlike [GuideSelectedPerson] which
/// stays independent per feature (matching TodaySelectedPerson/
/// ChallengeSelectedPerson).

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

/// Which household member's tab is active on the Guide tab — same shape
/// as TodaySelectedPerson/ChallengeSelectedPerson, kept independent per
/// feature by established convention.

@ProviderFor(GuideSelectedPerson)
const guideSelectedPersonProvider = GuideSelectedPersonProvider._();

/// Which household member's tab is active on the Guide tab — same shape
/// as TodaySelectedPerson/ChallengeSelectedPerson, kept independent per
/// feature by established convention.
final class GuideSelectedPersonProvider
    extends $NotifierProvider<GuideSelectedPerson, String> {
  /// Which household member's tab is active on the Guide tab — same shape
  /// as TodaySelectedPerson/ChallengeSelectedPerson, kept independent per
  /// feature by established convention.
  const GuideSelectedPersonProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guideSelectedPersonProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guideSelectedPersonHash();

  @$internal
  @override
  GuideSelectedPerson create() => GuideSelectedPerson();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$guideSelectedPersonHash() =>
    r'31542a4898aaa7bfae8062c27ea1d32c671e8252';

/// Which household member's tab is active on the Guide tab — same shape
/// as TodaySelectedPerson/ChallengeSelectedPerson, kept independent per
/// feature by established convention.

abstract class _$GuideSelectedPerson extends $Notifier<String> {
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

/// Per-person completion rows for one date, read straight through from
/// [GuideRepository] — no local edit buffer. Every mutation method here
/// calls the repository (a real write against Supabase, or a mutation of
/// StaticGuideRepository's in-memory map in tests) and then invalidates
/// this provider so the UI reflects whatever the repository now reports,
/// rather than optimistically guessing at the new state itself.

@ProviderFor(GuideDevotionalProgress)
const guideDevotionalProgressProvider = GuideDevotionalProgressFamily._();

/// Per-person completion rows for one date, read straight through from
/// [GuideRepository] — no local edit buffer. Every mutation method here
/// calls the repository (a real write against Supabase, or a mutation of
/// StaticGuideRepository's in-memory map in tests) and then invalidates
/// this provider so the UI reflects whatever the repository now reports,
/// rather than optimistically guessing at the new state itself.
final class GuideDevotionalProgressProvider
    extends
        $AsyncNotifierProvider<
          GuideDevotionalProgress,
          Map<String, FieldGuideDailyDevotionalMember>
        > {
  /// Per-person completion rows for one date, read straight through from
  /// [GuideRepository] — no local edit buffer. Every mutation method here
  /// calls the repository (a real write against Supabase, or a mutation of
  /// StaticGuideRepository's in-memory map in tests) and then invalidates
  /// this provider so the UI reflects whatever the repository now reports,
  /// rather than optimistically guessing at the new state itself.
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
    r'7beb0a3e33dede06800e59d67af0cf1aedf62cda';

/// Per-person completion rows for one date, read straight through from
/// [GuideRepository] — no local edit buffer. Every mutation method here
/// calls the repository (a real write against Supabase, or a mutation of
/// StaticGuideRepository's in-memory map in tests) and then invalidates
/// this provider so the UI reflects whatever the repository now reports,
/// rather than optimistically guessing at the new state itself.

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

  /// Per-person completion rows for one date, read straight through from
  /// [GuideRepository] — no local edit buffer. Every mutation method here
  /// calls the repository (a real write against Supabase, or a mutation of
  /// StaticGuideRepository's in-memory map in tests) and then invalidates
  /// this provider so the UI reflects whatever the repository now reports,
  /// rather than optimistically guessing at the new state itself.

  GuideDevotionalProgressProvider call(DateTime date) =>
      GuideDevotionalProgressProvider._(argument: date, from: this);

  @override
  String toString() => r'guideDevotionalProgressProvider';
}

/// Per-person completion rows for one date, read straight through from
/// [GuideRepository] — no local edit buffer. Every mutation method here
/// calls the repository (a real write against Supabase, or a mutation of
/// StaticGuideRepository's in-memory map in tests) and then invalidates
/// this provider so the UI reflects whatever the repository now reports,
/// rather than optimistically guessing at the new state itself.

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

String _$guideBaseStreakHash() => r'0a020bd412df6a7b37fa431aaab30c0ab8133183';

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

/// Fake temperament-quiz-result seed — see models/temperament.dart. Only
/// 'you' has "taken the quiz" for now; everyone else renders the Find Your
/// Temperament button instead of Primary/Secondary tags, until [save] is
/// called with a freshly-scored result from TemperamentQuizScreen. In-memory
/// only, same as ChallengeProgress/EventRsvp — resets on app restart.

@ProviderFor(GuideTemperamentResult)
const guideTemperamentResultProvider = GuideTemperamentResultFamily._();

/// Fake temperament-quiz-result seed — see models/temperament.dart. Only
/// 'you' has "taken the quiz" for now; everyone else renders the Find Your
/// Temperament button instead of Primary/Secondary tags, until [save] is
/// called with a freshly-scored result from TemperamentQuizScreen. In-memory
/// only, same as ChallengeProgress/EventRsvp — resets on app restart.
final class GuideTemperamentResultProvider
    extends $NotifierProvider<GuideTemperamentResult, TemperamentResult?> {
  /// Fake temperament-quiz-result seed — see models/temperament.dart. Only
  /// 'you' has "taken the quiz" for now; everyone else renders the Find Your
  /// Temperament button instead of Primary/Secondary tags, until [save] is
  /// called with a freshly-scored result from TemperamentQuizScreen. In-memory
  /// only, same as ChallengeProgress/EventRsvp — resets on app restart.
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TemperamentResult? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TemperamentResult?>(value),
    );
  }

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
    r'0ae6bc2acb223e3ad5eb52382d274cdaba0e85b7';

/// Fake temperament-quiz-result seed — see models/temperament.dart. Only
/// 'you' has "taken the quiz" for now; everyone else renders the Find Your
/// Temperament button instead of Primary/Secondary tags, until [save] is
/// called with a freshly-scored result from TemperamentQuizScreen. In-memory
/// only, same as ChallengeProgress/EventRsvp — resets on app restart.

final class GuideTemperamentResultFamily extends $Family
    with
        $ClassFamilyOverride<
          GuideTemperamentResult,
          TemperamentResult?,
          TemperamentResult?,
          TemperamentResult?,
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

  /// Fake temperament-quiz-result seed — see models/temperament.dart. Only
  /// 'you' has "taken the quiz" for now; everyone else renders the Find Your
  /// Temperament button instead of Primary/Secondary tags, until [save] is
  /// called with a freshly-scored result from TemperamentQuizScreen. In-memory
  /// only, same as ChallengeProgress/EventRsvp — resets on app restart.

  GuideTemperamentResultProvider call(String personKey) =>
      GuideTemperamentResultProvider._(argument: personKey, from: this);

  @override
  String toString() => r'guideTemperamentResultProvider';
}

/// Fake temperament-quiz-result seed — see models/temperament.dart. Only
/// 'you' has "taken the quiz" for now; everyone else renders the Find Your
/// Temperament button instead of Primary/Secondary tags, until [save] is
/// called with a freshly-scored result from TemperamentQuizScreen. In-memory
/// only, same as ChallengeProgress/EventRsvp — resets on app restart.

abstract class _$GuideTemperamentResult extends $Notifier<TemperamentResult?> {
  late final _$args = ref.$arg as String;
  String get personKey => _$args;

  TemperamentResult? build(String personKey);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<TemperamentResult?, TemperamentResult?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TemperamentResult?, TemperamentResult?>,
              TemperamentResult?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// In-memory-only liked/favorited items (Identity, Wisdom, and quote
/// cards). Entries are composite '$personKey:$itemId' strings. Not
/// persisted — no favorite field exists anywhere in the Field Guide
/// schema, so this is a visual affordance only, resetting on restart.

@ProviderFor(GuideLikedItems)
const guideLikedItemsProvider = GuideLikedItemsProvider._();

/// In-memory-only liked/favorited items (Identity, Wisdom, and quote
/// cards). Entries are composite '$personKey:$itemId' strings. Not
/// persisted — no favorite field exists anywhere in the Field Guide
/// schema, so this is a visual affordance only, resetting on restart.
final class GuideLikedItemsProvider
    extends $NotifierProvider<GuideLikedItems, Set<String>> {
  /// In-memory-only liked/favorited items (Identity, Wisdom, and quote
  /// cards). Entries are composite '$personKey:$itemId' strings. Not
  /// persisted — no favorite field exists anywhere in the Field Guide
  /// schema, so this is a visual affordance only, resetting on restart.
  const GuideLikedItemsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guideLikedItemsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guideLikedItemsHash();

  @$internal
  @override
  GuideLikedItems create() => GuideLikedItems();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$guideLikedItemsHash() => r'02cc178503182cacdc21d23f6dc4d477316ab976';

/// In-memory-only liked/favorited items (Identity, Wisdom, and quote
/// cards). Entries are composite '$personKey:$itemId' strings. Not
/// persisted — no favorite field exists anywhere in the Field Guide
/// schema, so this is a visual affordance only, resetting on restart.

abstract class _$GuideLikedItems extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
