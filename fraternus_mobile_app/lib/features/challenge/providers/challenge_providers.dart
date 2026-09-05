import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/clock_provider.dart';
import '../../../app/supabase_provider.dart';
import '../../profile/models/member.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/challenge_repository.dart';
import '../models/challenge_household_member.dart';
import '../models/challenge_member_rep.dart';
import '../models/person_challenge_progress.dart';
import '../models/weekly_challenge.dart';

part 'challenge_providers.g.dart';

@riverpod
ChallengeRepository challengeRepository(Ref ref) {
  return SupabaseChallengeRepository(ref.watch(supabaseClientProvider));
}

/// Every household Member's own chapter should in practice be the same one
/// (app_concept.md doesn't describe a multi-chapter household) — the first
/// member's chapter stands in for "the household's chapter", same
/// simplification guide_providers.dart makes for Field Guide content.
String? _householdChapterKey(List<Member> members) =>
    members.isEmpty ? null : members.first.chapterKey;

/// The current user's household, for the Challenge tab's person tabs.
/// Sourced from Profile's real Member data now — every Member is eligible
/// for every Challenge per the schema (no per-challenge eligibility table
/// the way Events has), so this stays a plain household-wide list.
@riverpod
Future<List<ChallengeHouseholdMember>> challengeHousehold(Ref ref) async {
  final members = await ref.watch(householdMembersProvider.future);
  return [
    for (final member in members)
      ChallengeHouseholdMember(memberId: member.id, label: member.firstName),
  ];
}

/// Source of truth for [allChallengesProvider]/[currentChallengeProvider]/
/// [pastChallengesProvider] — fetched once so the three stay consistent
/// with each other instead of each re-deriving "current" independently.
@riverpod
Future<ChallengeFeed> _challengeFeed(Ref ref) async {
  final repository = ref.watch(challengeRepositoryProvider);
  final members = await ref.watch(householdMembersProvider.future);
  final chapterKey = _householdChapterKey(members);
  if (chapterKey == null) {
    return const ChallengeFeed(challenges: [], currentChallengeId: null);
  }
  return repository.fetchChallenges(
    asOf: ref.watch(nowProvider),
    chapterKey: chapterKey,
    memberLabels: {for (final member in members) member.id: member.firstName},
  );
}

/// All challenges the chapter has ever had, by template date descending.
@riverpod
Future<List<WeeklyChallenge>> allChallenges(Ref ref) async {
  final feed = await ref.watch(_challengeFeedProvider.future);
  return feed.challenges;
}

/// The challenge tied to the most recent past Frat Night, or null if there
/// isn't one right now (no Frat Night yet, or the most recent one is more
/// than [currentChallengeMaxAge] old) — see ChallengeRepository.fetchChallenges.
@riverpod
Future<WeeklyChallenge?> currentChallenge(Ref ref) async {
  final feed = await ref.watch(_challengeFeedProvider.future);
  if (feed.currentChallengeId == null) return null;
  for (final challenge in feed.challenges) {
    if (challenge.id == feed.currentChallengeId) return challenge;
  }
  return null;
}

@riverpod
Future<List<WeeklyChallenge>> pastChallenges(Ref ref) async {
  final feed = await ref.watch(_challengeFeedProvider.future);
  return [
    for (final challenge in feed.challenges)
      if (challenge.id != feed.currentChallengeId) challenge,
  ];
}

@riverpod
Future<WeeklyChallenge?> challengeById(Ref ref, String challengeId) async {
  final challenges = await ref.watch(allChallengesProvider.future);
  for (final challenge in challenges) {
    if (challenge.id == challengeId) return challenge;
  }
  return null;
}

/// Consecutive completed challenges for [personKey], most recent first,
/// stopping at the first not-yet-completed one — streak is purely computed
/// client-side (per docs/app_concept.md's Logic section), never a stored
/// field on [PersonChallengeProgress].
@riverpod
Future<int> challengeStreak(Ref ref, String personKey) async {
  final challenges = await ref.watch(allChallengesProvider.future);
  final now = ref.watch(nowProvider);
  var streak = 0;
  for (final challenge in challenges) {
    // allChallenges includes Challenges for Frat Nights that haven't
    // happened yet (content gets seeded ahead of time) — sorted first since
    // they're the most recent by date, they'd otherwise always short-
    // circuit the streak to 0 via the null-progress break below. A
    // not-yet-happened challenge can't count for or against the streak.
    if (challenge.fratNightDate.isAfter(now)) continue;
    final progressByPerson = await ref.watch(
      challengeProgressProvider(challenge.id).future,
    );
    final progress = progressByPerson[personKey];
    if (progress == null || !progress.isCompleted) break;
    streak++;
  }
  return streak;
}

/// Per-person progress for one challenge, read straight through from
/// [ChallengeRepository] — no local edit buffer. Every mutation calls the
/// repository and invalidates the shared challenge feed (which this
/// provider derives from via challengeByIdProvider), so a write is only
/// ever reflected once the repository actually reports it back.
@riverpod
class ChallengeProgress extends _$ChallengeProgress {
  @override
  Future<Map<String, PersonChallengeProgress>> build(String challengeId) async {
    final challenge = await ref.watch(
      challengeByIdProvider(challengeId).future,
    );
    return {
      for (final progress in challenge?.progress ?? const [])
        progress.memberId: progress,
    };
  }

  /// Accepting is what creates the `Challenge Member` row in the first
  /// place (mirroring `Event RSVP`'s "no row until submitted" rule).
  Future<void> accept(String personKey) async {
    final current = state.value ?? const {};
    if (current.containsKey(personKey)) return;
    await ref
        .read(challengeRepositoryProvider)
        .acceptChallenge(memberId: personKey, challengeId: challengeId);
    ref.invalidate(_challengeFeedProvider);
  }

  /// Marks the rep at [repIndex] complete (today's date) if it's currently
  /// incomplete, or clears it back to incomplete if it's already done —
  /// used both for "Mark Complete" on the current challenge's next rep and
  /// for Past Challenges' any-order retroactive dot taps.
  ///
  /// Updates [state] optimistically — including [PersonChallengeProgress
  /// .completedDate], mirroring the same reps-vs-repsTotal completion rule
  /// the repository applies server-side (see StaticChallengeRepository
  /// .toggleChallengeRep) — so both the rep dot and, on the last rep, the
  /// completion card flip instantly instead of waiting on the round trip.
  /// Rolls back on failure. Still invalidates [_challengeFeedProvider]
  /// afterwards so streak/other-screen reads don't go stale, paired with
  /// `skipLoadingOnReload: true` in the screens so that background reload
  /// stays invisible rather than a blank-then-repaint flash.
  Future<void> toggleRep(String personKey, int repIndex) async {
    final current = state.value ?? const {};
    final existing = current[personKey];
    if (existing == null) return;

    final repNumber = repIndex + 1;
    final hasRep = existing.reps.any((rep) => rep.number == repNumber);
    final optimisticReps = hasRep
        ? existing.reps.where((rep) => rep.number != repNumber).toList()
        : [
            ...existing.reps,
            ChallengeMemberRep(
              id: '${existing.id}-pending-rep-$repNumber',
              challengeMemberId: existing.id,
              completedByUserId: '',
              number: repNumber,
              createdAt: DateTime.now(),
            ),
          ];

    final challenge = await ref.read(challengeByIdProvider(challengeId).future);
    final repsTotal = challenge?.repsTotal;
    final isNowComplete =
        repsTotal != null && optimisticReps.length == repsTotal;

    final previous = state;
    state = AsyncData({
      ...current,
      personKey: existing.copyWith(
        reps: optimisticReps,
        completedDate: isNowComplete ? DateTime.now() : null,
        clearCompletedDate: !isNowComplete,
      ),
    });

    try {
      await ref
          .read(challengeRepositoryProvider)
          .toggleChallengeRep(
            challengeMemberId: existing.id,
            repNumber: repNumber,
          );
    } catch (_) {
      state = previous;
      rethrow;
    }
    ref.invalidate(_challengeFeedProvider);
  }
}
