import '../../../shared/models/frat_night_template.dart';
import 'person_challenge_progress.dart';

/// Adapted from docs/app_concept.md's `Challenge` table. 1:1 with a
/// [FratNightTemplate] — the "current" challenge is the one whose template
/// is the most recent past (non-cancelled) Frat Night's template, and that
/// template's `startOfWeekDate` is what drives the challenge's effective
/// start (not a separate field here).
class WeeklyChallenge {
  const WeeklyChallenge({
    required this.id,
    required this.fratNightTemplateId,
    required this.fratNightTemplate,
    required this.title,
    required this.description,
    required this.repsTotal,
    required this.progress,
  });

  final String id;
  final String fratNightTemplateId;

  /// Nested read-model join, same pattern as `FieldGuideWeek.quotes` — gives
  /// direct access to `fratNightTemplate.startOfWeekDate` for the "Week of
  /// ..." label and the 48h "NEW" window without a second lookup.
  final FratNightTemplate fratNightTemplate;
  final String title;
  final String description;
  final int repsTotal;

  /// One entry per household member, in a fixed you/jack/thomas order.
  final List<PersonChallengeProgress> progress;
}
