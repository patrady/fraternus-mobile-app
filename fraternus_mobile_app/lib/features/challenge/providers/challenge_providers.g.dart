// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'challenge_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(challengeRepository)
const challengeRepositoryProvider = ChallengeRepositoryProvider._();

final class ChallengeRepositoryProvider
    extends
        $FunctionalProvider<
          ChallengeRepository,
          ChallengeRepository,
          ChallengeRepository
        >
    with $Provider<ChallengeRepository> {
  const ChallengeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'challengeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$challengeRepositoryHash();

  @$internal
  @override
  $ProviderElement<ChallengeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ChallengeRepository create(Ref ref) {
    return challengeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ChallengeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ChallengeRepository>(value),
    );
  }
}

String _$challengeRepositoryHash() =>
    r'05add44338b30ccb79d95c4a6e1274ed497a57b1';

/// The current user's household, for the Challenge tab's person tabs.
/// Sourced from Profile's real Member data now — every Member is eligible
/// for every Challenge per the schema (no per-challenge eligibility table
/// the way Events has), so this stays a plain household-wide list.

@ProviderFor(challengeHousehold)
const challengeHouseholdProvider = ChallengeHouseholdProvider._();

/// The current user's household, for the Challenge tab's person tabs.
/// Sourced from Profile's real Member data now — every Member is eligible
/// for every Challenge per the schema (no per-challenge eligibility table
/// the way Events has), so this stays a plain household-wide list.

final class ChallengeHouseholdProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ChallengeHouseholdMember>>,
          List<ChallengeHouseholdMember>,
          FutureOr<List<ChallengeHouseholdMember>>
        >
    with
        $FutureModifier<List<ChallengeHouseholdMember>>,
        $FutureProvider<List<ChallengeHouseholdMember>> {
  /// The current user's household, for the Challenge tab's person tabs.
  /// Sourced from Profile's real Member data now — every Member is eligible
  /// for every Challenge per the schema (no per-challenge eligibility table
  /// the way Events has), so this stays a plain household-wide list.
  const ChallengeHouseholdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'challengeHouseholdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$challengeHouseholdHash();

  @$internal
  @override
  $FutureProviderElement<List<ChallengeHouseholdMember>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ChallengeHouseholdMember>> create(Ref ref) {
    return challengeHousehold(ref);
  }
}

String _$challengeHouseholdHash() =>
    r'3efdf57c8bc7e475ef2f8e2872e5bd47783f9d16';

/// Source of truth for [allChallengesProvider]/[currentChallengeProvider]/
/// [pastChallengesProvider] — fetched once so the three stay consistent
/// with each other instead of each re-deriving "current" independently.

@ProviderFor(_challengeFeed)
const _challengeFeedProvider = _ChallengeFeedProvider._();

/// Source of truth for [allChallengesProvider]/[currentChallengeProvider]/
/// [pastChallengesProvider] — fetched once so the three stay consistent
/// with each other instead of each re-deriving "current" independently.

final class _ChallengeFeedProvider
    extends
        $FunctionalProvider<
          AsyncValue<ChallengeFeed>,
          ChallengeFeed,
          FutureOr<ChallengeFeed>
        >
    with $FutureModifier<ChallengeFeed>, $FutureProvider<ChallengeFeed> {
  /// Source of truth for [allChallengesProvider]/[currentChallengeProvider]/
  /// [pastChallengesProvider] — fetched once so the three stay consistent
  /// with each other instead of each re-deriving "current" independently.
  const _ChallengeFeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'_challengeFeedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$_challengeFeedHash();

  @$internal
  @override
  $FutureProviderElement<ChallengeFeed> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ChallengeFeed> create(Ref ref) {
    return _challengeFeed(ref);
  }
}

String _$_challengeFeedHash() => r'f2186e69e64411cd0c67ca6457f32473fc010e06';

/// All challenges the chapter has ever had, by template date descending.

@ProviderFor(allChallenges)
const allChallengesProvider = AllChallengesProvider._();

/// All challenges the chapter has ever had, by template date descending.

final class AllChallengesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WeeklyChallenge>>,
          List<WeeklyChallenge>,
          FutureOr<List<WeeklyChallenge>>
        >
    with
        $FutureModifier<List<WeeklyChallenge>>,
        $FutureProvider<List<WeeklyChallenge>> {
  /// All challenges the chapter has ever had, by template date descending.
  const AllChallengesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allChallengesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allChallengesHash();

  @$internal
  @override
  $FutureProviderElement<List<WeeklyChallenge>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WeeklyChallenge>> create(Ref ref) {
    return allChallenges(ref);
  }
}

String _$allChallengesHash() => r'2a5353b69f2bc93811ab7b745659902df45688e8';

/// The challenge tied to the most recent past Frat Night, or null if there
/// isn't one right now (no Frat Night yet, or the most recent one is more
/// than [currentChallengeMaxAge] old) — see ChallengeRepository.fetchChallenges.

@ProviderFor(currentChallenge)
const currentChallengeProvider = CurrentChallengeProvider._();

/// The challenge tied to the most recent past Frat Night, or null if there
/// isn't one right now (no Frat Night yet, or the most recent one is more
/// than [currentChallengeMaxAge] old) — see ChallengeRepository.fetchChallenges.

final class CurrentChallengeProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeeklyChallenge?>,
          WeeklyChallenge?,
          FutureOr<WeeklyChallenge?>
        >
    with $FutureModifier<WeeklyChallenge?>, $FutureProvider<WeeklyChallenge?> {
  /// The challenge tied to the most recent past Frat Night, or null if there
  /// isn't one right now (no Frat Night yet, or the most recent one is more
  /// than [currentChallengeMaxAge] old) — see ChallengeRepository.fetchChallenges.
  const CurrentChallengeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentChallengeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentChallengeHash();

  @$internal
  @override
  $FutureProviderElement<WeeklyChallenge?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WeeklyChallenge?> create(Ref ref) {
    return currentChallenge(ref);
  }
}

String _$currentChallengeHash() => r'70d5b52d22d986d78e9a08abfa919cf72ab8a4dd';

@ProviderFor(pastChallenges)
const pastChallengesProvider = PastChallengesProvider._();

final class PastChallengesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WeeklyChallenge>>,
          List<WeeklyChallenge>,
          FutureOr<List<WeeklyChallenge>>
        >
    with
        $FutureModifier<List<WeeklyChallenge>>,
        $FutureProvider<List<WeeklyChallenge>> {
  const PastChallengesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pastChallengesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pastChallengesHash();

  @$internal
  @override
  $FutureProviderElement<List<WeeklyChallenge>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WeeklyChallenge>> create(Ref ref) {
    return pastChallenges(ref);
  }
}

String _$pastChallengesHash() => r'424e038cadf9a842e77b123a81b27d59a28191d8';

@ProviderFor(challengeById)
const challengeByIdProvider = ChallengeByIdFamily._();

final class ChallengeByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeeklyChallenge?>,
          WeeklyChallenge?,
          FutureOr<WeeklyChallenge?>
        >
    with $FutureModifier<WeeklyChallenge?>, $FutureProvider<WeeklyChallenge?> {
  const ChallengeByIdProvider._({
    required ChallengeByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'challengeByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$challengeByIdHash();

  @override
  String toString() {
    return r'challengeByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<WeeklyChallenge?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WeeklyChallenge?> create(Ref ref) {
    final argument = this.argument as String;
    return challengeById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$challengeByIdHash() => r'b8d69f550b3a7ea4077e9d7c394bb47b4cae1951';

final class ChallengeByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<WeeklyChallenge?>, String> {
  const ChallengeByIdFamily._()
    : super(
        retry: null,
        name: r'challengeByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ChallengeByIdProvider call(String challengeId) =>
      ChallengeByIdProvider._(argument: challengeId, from: this);

  @override
  String toString() => r'challengeByIdProvider';
}

/// Consecutive completed challenges for [personKey], most recent first,
/// stopping at the first not-yet-completed one — streak is purely computed
/// client-side (per docs/app_concept.md's Logic section), never a stored
/// field on [PersonChallengeProgress].

@ProviderFor(challengeStreak)
const challengeStreakProvider = ChallengeStreakFamily._();

/// Consecutive completed challenges for [personKey], most recent first,
/// stopping at the first not-yet-completed one — streak is purely computed
/// client-side (per docs/app_concept.md's Logic section), never a stored
/// field on [PersonChallengeProgress].

final class ChallengeStreakProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Consecutive completed challenges for [personKey], most recent first,
  /// stopping at the first not-yet-completed one — streak is purely computed
  /// client-side (per docs/app_concept.md's Logic section), never a stored
  /// field on [PersonChallengeProgress].
  const ChallengeStreakProvider._({
    required ChallengeStreakFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'challengeStreakProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$challengeStreakHash();

  @override
  String toString() {
    return r'challengeStreakProvider'
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
    return challengeStreak(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ChallengeStreakProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$challengeStreakHash() => r'42a27a2de7d79aaad5da8a2833a4a990e70f08ee';

/// Consecutive completed challenges for [personKey], most recent first,
/// stopping at the first not-yet-completed one — streak is purely computed
/// client-side (per docs/app_concept.md's Logic section), never a stored
/// field on [PersonChallengeProgress].

final class ChallengeStreakFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<int>, String> {
  const ChallengeStreakFamily._()
    : super(
        retry: null,
        name: r'challengeStreakProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Consecutive completed challenges for [personKey], most recent first,
  /// stopping at the first not-yet-completed one — streak is purely computed
  /// client-side (per docs/app_concept.md's Logic section), never a stored
  /// field on [PersonChallengeProgress].

  ChallengeStreakProvider call(String personKey) =>
      ChallengeStreakProvider._(argument: personKey, from: this);

  @override
  String toString() => r'challengeStreakProvider';
}

/// Which household member's tab is active on the Challenge tab — same
/// shape as TodaySelectedPerson, kept separate since Today and Challenge
/// select independently.

@ProviderFor(ChallengeSelectedPerson)
const challengeSelectedPersonProvider = ChallengeSelectedPersonProvider._();

/// Which household member's tab is active on the Challenge tab — same
/// shape as TodaySelectedPerson, kept separate since Today and Challenge
/// select independently.
final class ChallengeSelectedPersonProvider
    extends $NotifierProvider<ChallengeSelectedPerson, String> {
  /// Which household member's tab is active on the Challenge tab — same
  /// shape as TodaySelectedPerson, kept separate since Today and Challenge
  /// select independently.
  const ChallengeSelectedPersonProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'challengeSelectedPersonProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$challengeSelectedPersonHash();

  @$internal
  @override
  ChallengeSelectedPerson create() => ChallengeSelectedPerson();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$challengeSelectedPersonHash() =>
    r'4fbc82ca4cfe9eeb2720943adb9f514b81a0bf31';

/// Which household member's tab is active on the Challenge tab — same
/// shape as TodaySelectedPerson, kept separate since Today and Challenge
/// select independently.

abstract class _$ChallengeSelectedPerson extends $Notifier<String> {
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

/// Per-person progress for one challenge, read straight through from
/// [ChallengeRepository] — no local edit buffer. Every mutation calls the
/// repository and invalidates the shared challenge feed (which this
/// provider derives from via challengeByIdProvider), so a write is only
/// ever reflected once the repository actually reports it back.

@ProviderFor(ChallengeProgress)
const challengeProgressProvider = ChallengeProgressFamily._();

/// Per-person progress for one challenge, read straight through from
/// [ChallengeRepository] — no local edit buffer. Every mutation calls the
/// repository and invalidates the shared challenge feed (which this
/// provider derives from via challengeByIdProvider), so a write is only
/// ever reflected once the repository actually reports it back.
final class ChallengeProgressProvider
    extends
        $AsyncNotifierProvider<
          ChallengeProgress,
          Map<String, PersonChallengeProgress>
        > {
  /// Per-person progress for one challenge, read straight through from
  /// [ChallengeRepository] — no local edit buffer. Every mutation calls the
  /// repository and invalidates the shared challenge feed (which this
  /// provider derives from via challengeByIdProvider), so a write is only
  /// ever reflected once the repository actually reports it back.
  const ChallengeProgressProvider._({
    required ChallengeProgressFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'challengeProgressProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$challengeProgressHash();

  @override
  String toString() {
    return r'challengeProgressProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ChallengeProgress create() => ChallengeProgress();

  @override
  bool operator ==(Object other) {
    return other is ChallengeProgressProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$challengeProgressHash() => r'cc37ef0b579fb693d0094137db774c058d117ecf';

/// Per-person progress for one challenge, read straight through from
/// [ChallengeRepository] — no local edit buffer. Every mutation calls the
/// repository and invalidates the shared challenge feed (which this
/// provider derives from via challengeByIdProvider), so a write is only
/// ever reflected once the repository actually reports it back.

final class ChallengeProgressFamily extends $Family
    with
        $ClassFamilyOverride<
          ChallengeProgress,
          AsyncValue<Map<String, PersonChallengeProgress>>,
          Map<String, PersonChallengeProgress>,
          FutureOr<Map<String, PersonChallengeProgress>>,
          String
        > {
  const ChallengeProgressFamily._()
    : super(
        retry: null,
        name: r'challengeProgressProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Per-person progress for one challenge, read straight through from
  /// [ChallengeRepository] — no local edit buffer. Every mutation calls the
  /// repository and invalidates the shared challenge feed (which this
  /// provider derives from via challengeByIdProvider), so a write is only
  /// ever reflected once the repository actually reports it back.

  ChallengeProgressProvider call(String challengeId) =>
      ChallengeProgressProvider._(argument: challengeId, from: this);

  @override
  String toString() => r'challengeProgressProvider';
}

/// Per-person progress for one challenge, read straight through from
/// [ChallengeRepository] — no local edit buffer. Every mutation calls the
/// repository and invalidates the shared challenge feed (which this
/// provider derives from via challengeByIdProvider), so a write is only
/// ever reflected once the repository actually reports it back.

abstract class _$ChallengeProgress
    extends $AsyncNotifier<Map<String, PersonChallengeProgress>> {
  late final _$args = ref.$arg as String;
  String get challengeId => _$args;

  FutureOr<Map<String, PersonChallengeProgress>> build(String challengeId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref =
        this.ref
            as $Ref<
              AsyncValue<Map<String, PersonChallengeProgress>>,
              Map<String, PersonChallengeProgress>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<Map<String, PersonChallengeProgress>>,
                Map<String, PersonChallengeProgress>
              >,
              AsyncValue<Map<String, PersonChallengeProgress>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
