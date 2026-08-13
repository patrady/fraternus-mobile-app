import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/challenge_repository.dart';
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
  return challenges..sort((a, b) => b.startAt.compareTo(a.startAt));
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
    return {for (final progress in challenge?.progress ?? const []) progress.personKey: progress};
  }

  void accept(String personKey) {
    final current = state.value ?? const {};
    final existing = current[personKey];
    if (existing == null) return;
    state = AsyncData({...current, personKey: existing.copyWith(accepted: true)});
  }

  /// Marks the rep at [repIndex] complete (today's date) if it's currently
  /// incomplete, or clears it back to incomplete if it's already done —
  /// used both for "Mark Complete" on the current challenge's next rep and
  /// for Past Challenges' any-order retroactive dot taps.
  void toggleRep(String personKey, int repIndex) {
    final current = state.value ?? const {};
    final existing = current[personKey];
    if (existing == null) return;
    final reps = [...existing.repCompletions];
    reps[repIndex] = reps[repIndex] == null ? DateTime.now() : null;
    state = AsyncData({...current, personKey: existing.copyWith(repCompletions: reps)});
  }
}
