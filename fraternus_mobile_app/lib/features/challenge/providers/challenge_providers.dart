import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/challenge_repository.dart';
import '../models/challenge_member_rep.dart';
import '../models/person_challenge_progress.dart';
import '../models/weekly_challenge.dart';

part 'challenge_providers.g.dart';

/// Swap this provider's implementation to change where Challenge's data
/// comes from — nothing downstream needs to change.
@riverpod
ChallengeRepository challengeRepository(Ref ref) {
  return const StaticChallengeRepository();
}

/// All challenges, most recently started first.
@riverpod
Future<List<WeeklyChallenge>> allChallenges(Ref ref) async {
  final repository = ref.watch(challengeRepositoryProvider);
  final challenges = await repository.fetchChallenges(asOf: DateTime.now());
  return challenges..sort(
    (a, b) => b.fratNightTemplate.startOfWeekDate.compareTo(a.fratNightTemplate.startOfWeekDate),
  );
}

@riverpod
Future<WeeklyChallenge> currentChallenge(Ref ref) async {
  final challenges = await ref.watch(allChallengesProvider.future);
  return challenges.first;
}

@riverpod
Future<List<WeeklyChallenge>> pastChallenges(Ref ref) async {
  final challenges = await ref.watch(allChallengesProvider.future);
  return challenges.skip(1).toList();
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
  var streak = 0;
  for (final challenge in challenges) {
    final progressByPerson = await ref.watch(challengeProgressProvider(challenge.id).future);
    final progress = progressByPerson[personKey];
    if (progress == null || !progress.isCompleted) break;
    streak++;
  }
  return streak;
}

/// Which household member's tab is active on the Challenge tab — same
/// shape as TodaySelectedPerson, kept separate since Today and Challenge
/// select independently.
@riverpod
class ChallengeSelectedPerson extends _$ChallengeSelectedPerson {
  @override
  String build() => 'you';

  void select(String key) => state = key;
}

/// In-memory accept/complete edits for one challenge's household rows,
/// keyed by person. Seeded from the challenge's own data, then locally
/// overridden as the user accepts or completes reps — edits reset on app
/// restart, same as [EventRsvp].
@riverpod
class ChallengeProgress extends _$ChallengeProgress {
  @override
  Future<Map<String, PersonChallengeProgress>> build(String challengeId) async {
    final challenge = await ref.watch(challengeByIdProvider(challengeId).future);
    return {for (final progress in challenge?.progress ?? const []) progress.memberId: progress};
  }

  void accept(String personKey) {
    final current = state.value ?? const {};
    final existing = current[personKey];
    if (existing == null) return;
    state = AsyncData({...current, personKey: existing.copyWith(committedDate: DateTime.now())});
  }

  /// Marks the rep at [repIndex] complete (today's date) if it's currently
  /// incomplete, or clears it back to incomplete if it's already done —
  /// used both for "Mark Complete" on the current challenge's next rep and
  /// for Past Challenges' any-order retroactive dot taps. Both call sites
  /// only ever touch the boundary rep (the next incomplete slot, or the
  /// most recently completed one), matching the schema's "a Challenge
  /// Member Rep row only exists once completed" rule.
  void toggleRep(String personKey, int repIndex) {
    final current = state.value ?? const {};
    final existing = current[personKey];
    if (existing == null) return;

    final repNumber = repIndex + 1;
    final hasRep = existing.reps.any((rep) => rep.number == repNumber);
    final reps = hasRep
        ? existing.reps.where((rep) => rep.number != repNumber).toList()
        : [
            ...existing.reps,
            ChallengeMemberRep(
              id: '${existing.id}-rep-$repNumber',
              challengeMemberId: existing.id,
              completedByUserId: 'user-john',
              number: repNumber,
              createdAt: DateTime.now(),
            ),
          ];

    final repsTotal = ref.read(challengeByIdProvider(challengeId)).value?.repsTotal;
    final isNowComplete = repsTotal != null && reps.length == repsTotal;
    final updated = existing.copyWith(
      reps: reps,
      completedDate: isNowComplete ? DateTime.now() : null,
      clearCompletedDate: !isNowComplete,
    );
    state = AsyncData({...current, personKey: updated});
  }
}
