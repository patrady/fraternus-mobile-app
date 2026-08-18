import 'challenge_member_rep.dart';

/// Adapted from docs/app_concept.md's `Challenge Member` table — one
/// household member's progress on a single [WeeklyChallenge]. A row only
/// exists once that member has actually accepted the challenge (mirroring
/// `Event RSVP`'s "no row until submitted" rule) — an eligible-but-not-yet-
/// accepted household member has no row at all (see
/// `ChallengeHouseholdMember` for how the UI knows to show them anyway).
///
/// [reps] holds only the reps actually completed so far (per the schema, a
/// [ChallengeMemberRep] row only exists once that rep is done) — the total
/// number of reps available comes from the parent `WeeklyChallenge.repsTotal`,
/// not duplicated here.
class PersonChallengeProgress {
  const PersonChallengeProgress({
    required this.id,
    required this.memberId,
    required this.challengeId,
    required this.label,
    required this.committedDate,
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

  /// Set at row-creation time — accepting the challenge is what creates
  /// this row in the first place.
  final DateTime committedDate;

  /// Set once every rep is complete.
  final DateTime? completedDate;
  final List<ChallengeMemberRep> reps;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  int get repsDone => reps.length;

  bool get isCompleted => completedDate != null;

  /// Streak is purely computed client-side from `Challenge Member`/
  /// `Challenge Member Rep` history — deliberately not a field here, so it
  /// can never be treated as something to store or sync.
  PersonChallengeProgress copyWith({
    DateTime? completedDate,
    bool clearCompletedDate = false,
    List<ChallengeMemberRep>? reps,
  }) {
    return PersonChallengeProgress(
      id: id,
      memberId: memberId,
      challengeId: challengeId,
      label: label,
      committedDate: committedDate,
      completedDate: clearCompletedDate ? null : (completedDate ?? this.completedDate),
      reps: reps ?? this.reps,
      createdAt: createdAt,
      lastModifiedAt: lastModifiedAt,
    );
  }

  /// [label] isn't a schema field (see the class doc) so it can't come from
  /// [json] alone — callers resolve it separately (from the household
  /// member list) and pass it in. Expects the nested-embed shape
  /// (`challenge_member_reps(*)`) for [reps] — see SupabaseChallengeRepository.
  factory PersonChallengeProgress.fromJson(Map<String, dynamic> json, {required String label}) {
    final repsJson = json['challenge_member_reps'] as List<dynamic>? ?? const [];
    return PersonChallengeProgress(
      id: json['id'] as String,
      memberId: json['member_id'] as String,
      challengeId: json['challenge_id'] as String,
      label: label,
      committedDate: DateTime.parse(json['committed_date'] as String),
      completedDate: json['completed_date'] == null ? null : DateTime.parse(json['completed_date'] as String),
      reps: [for (final repJson in repsJson) ChallengeMemberRep.fromJson(repJson as Map<String, dynamic>)],
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
