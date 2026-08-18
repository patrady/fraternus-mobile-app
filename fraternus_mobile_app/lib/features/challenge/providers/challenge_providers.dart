import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/supabase_provider.dart';
import '../../profile/models/member.dart';
import '../../profile/providers/profile_providers.dart';
import '../data/challenge_repository.dart';
import '../models/challenge_household_member.dart';
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
String? _householdChapterId(List<Member> members) => members.isEmpty ? null : members.first.chapterId;

/// The current user's household, for the Challenge tab's person tabs.
/// Sourced from Profile's real Member data now — every Member is eligible
/// for every Challenge per the schema (no per-challenge eligibility table
/// the way Events has), so this stays a plain household-wide list.
@riverpod
Future<List<ChallengeHouseholdMember>> challengeHousehold(Ref ref) async {
  final members = await ref.watch(householdMembersProvider.future);
  return [for (final member in members) ChallengeHouseholdMember(memberId: member.id, label: member.firstName)];
}

/// All challenges, current one first (see ChallengeRepository.fetchChallenges).
@riverpod
Future<List<WeeklyChallenge>> allChallenges(Ref ref) async {
  final repository = ref.watch(challengeRepositoryProvider);
  final members = await ref.watch(householdMembersProvider.future);
  final chapterId = _householdChapterId(members);
  if (chapterId == null) return const [];
  return repository.fetchChallenges(
    asOf: DateTime.now(),
    chapterId: chapterId,
    memberLabels: {for (final member in members) member.id: member.firstName},
  );
}

@riverpod
Future<WeeklyChallenge?> currentChallenge(Ref ref) async {
  final challenges = await ref.watch(allChallengesProvider.future);
  return challenges.isEmpty ? null : challenges.first;
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

/// Per-person progress for one challenge, read straight through from
/// [ChallengeRepository] — no local edit buffer. Every mutation calls the
/// repository and invalidates allChallengesProvider (which this provider
/// derives from via challengeByIdProvider), so a write is only ever
/// reflected once the repository actually reports it back.
@riverpod
class ChallengeProgress extends _$ChallengeProgress {
  @override
  Future<Map<String, PersonChallengeProgress>> build(String challengeId) async {
    final challenge = await ref.watch(challengeByIdProvider(challengeId).future);
    return {for (final progress in challenge?.progress ?? const []) progress.memberId: progress};
  }

  /// Accepting is what creates the `Challenge Member` row in the first
  /// place (mirroring `Event RSVP`'s "no row until submitted" rule).
  Future<void> accept(String personKey) async {
    final current = state.value ?? const {};
    if (current.containsKey(personKey)) return;
    await ref.read(challengeRepositoryProvider).acceptChallenge(memberId: personKey, challengeId: challengeId);
    ref.invalidate(allChallengesProvider);
  }

  /// Marks the rep at [repIndex] complete (today's date) if it's currently
  /// incomplete, or clears it back to incomplete if it's already done —
  /// used both for "Mark Complete" on the current challenge's next rep and
  /// for Past Challenges' any-order retroactive dot taps.
  Future<void> toggleRep(String personKey, int repIndex) async {
    final current = state.value ?? const {};
    final existing = current[personKey];
    if (existing == null) return;
    await ref.read(challengeRepositoryProvider).toggleChallengeRep(
      challengeMemberId: existing.id,
      repNumber: repIndex + 1,
    );
    ref.invalidate(allChallengesProvider);
  }
}
