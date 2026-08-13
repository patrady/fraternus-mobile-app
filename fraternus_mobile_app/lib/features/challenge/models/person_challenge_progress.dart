import 'challenge_member_rep.dart';

/// Adapted from docs/app_concept.md's `Challenge Member` table — one
/// household member's progress on a single [WeeklyChallenge]. [reps] holds
/// only the reps actually completed so far (per the schema, a
/// [ChallengeMemberRep] row only exists once that rep is done) — the total
/// number of reps available comes from the parent `WeeklyChallenge.repsTotal`,
/// not duplicated here.
class PersonChallengeProgress {
  const PersonChallengeProgress({
    required this.id,
    required this.memberId,
    required this.challengeId,
    required this.label,
    this.committedDate,
    this.completedDate,
    required this.reps,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String memberId;
  final String challengeId;

  /// Display name — a denormalized read-model convenience, not a schema
  /// field; joined from [Member] rather than stored/synced as-is.
  final String label;

  /// Set once the household member accepts the challenge.
  final DateTime? committedDate;

  /// Set once every rep is complete.
  final DateTime? completedDate;
  final List<ChallengeMemberRep> reps;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  bool get accepted => committedDate != null;

  int get repsDone => reps.length;

  bool get isCompleted => completedDate != null;

  /// Streak is purely computed client-side from `Challenge Member`/
  /// `Challenge Member Rep` history — deliberately not a field here, so it
  /// can never be treated as something to store or sync.
  PersonChallengeProgress copyWith({
    DateTime? committedDate,
    DateTime? completedDate,
    bool clearCompletedDate = false,
    List<ChallengeMemberRep>? reps,
  }) {
    return PersonChallengeProgress(
      id: id,
      memberId: memberId,
      challengeId: challengeId,
      label: label,
      committedDate: committedDate ?? this.committedDate,
      completedDate: clearCompletedDate ? null : (completedDate ?? this.completedDate),
      reps: reps ?? this.reps,
      createdAt: createdAt,
      lastModifiedAt: lastModifiedAt,
    );
  }
}
