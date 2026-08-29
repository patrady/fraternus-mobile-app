import '../../../shared/models/frat_night_template.dart';
import 'person_challenge_progress.dart';

/// Adapted from docs/app_concept.md's `Challenge` table. 1:1 with a
/// [FratNightTemplate] — the "current" challenge is the one whose template
/// is the most recent past (non-cancelled) Frat Night's template, and that
/// template's `startOfWeekDate` is what drives the challenge's effective
/// start (not a separate field here).
///
/// Unlike `Event`, there's no per-challenge eligibility list here — every
/// Member is eligible for every Challenge per the schema, so "which
/// household members can take this on" is a household-level concept (see
/// `ChallengeHouseholdMember`), not something that varies challenge to
/// challenge.
class WeeklyChallenge {
  const WeeklyChallenge({
    required this.id,
    required this.fratNightTemplateKey,
    required this.fratNightTemplate,
    required this.title,
    required this.description,
    required this.repsTotal,
    required this.progress,
  });

  final String id;
  final String fratNightTemplateKey;

  /// Nested read-model join, same pattern as `FieldGuideWeek.quotes` — gives
  /// direct access to `fratNightTemplate.startOfWeekDate` for the "Week of
  /// ..." label and the 48h "NEW" window without a second lookup.
  final FratNightTemplate fratNightTemplate;
  final String title;
  final String description;
  final int repsTotal;

  /// Only the household members who have actually accepted — a
  /// `Challenge Member` row doesn't exist until then.
  final List<PersonChallengeProgress> progress;

  /// Expects the nested-embed shape
  /// `*, frat_night_templates(*), challenge_members(*, challenge_member_reps(*))`
  /// — see SupabaseChallengeRepository. RLS already scopes the embedded
  /// `challenge_members` rows to the caller's own household, so nothing
  /// further is filtered here. [memberLabels] resolves each progress row's
  /// display name (not a schema field — see PersonChallengeProgress) from
  /// the household member list fetched separately.
  factory WeeklyChallenge.fromJson(Map<String, dynamic> json, {required Map<String, String> memberLabels}) {
    final progressJson = json['challenge_members'] as List<dynamic>? ?? const [];
    return WeeklyChallenge(
      id: json['id'] as String,
      fratNightTemplateKey: json['frat_night_template_key'] as String,
      fratNightTemplate: FratNightTemplate.fromJson(json['frat_night_templates'] as Map<String, dynamic>),
      title: json['title'] as String,
      description: json['description'] as String,
      repsTotal: json['reps'] as int,
      progress: [
        for (final progressRow in progressJson)
          PersonChallengeProgress.fromJson(
            progressRow as Map<String, dynamic>,
            label: memberLabels[progressRow['member_id']] ?? '',
          ),
      ],
    );
  }
}
