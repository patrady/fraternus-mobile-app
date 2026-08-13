import 'person_challenge_progress.dart';

class WeeklyChallenge {
  const WeeklyChallenge({
    required this.id,
    required this.title,
    required this.startAt,
    required this.description,
    required this.quote,
    required this.repsTotal,
    required this.progress,
  });

  final String id;
  final String title;

  /// Week start — drives the derived "Week of ..." label and the 48h
  /// "NEW" window.
  final DateTime startAt;
  final String description;

  /// Shown on the not-yet-accepted card, above the "Accept Challenge"
  /// button — distinct from [description], which is the info card's own
  /// summary of what the challenge involves.
  final String quote;
  final int repsTotal;

  /// One entry per household member, in a fixed you/jack/thomas order.
  final List<PersonChallengeProgress> progress;
}
