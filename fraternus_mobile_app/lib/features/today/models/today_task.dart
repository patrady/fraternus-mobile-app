/// What kind of thing a [TodayTask] is — a domain concept only. Mapping a
/// kind to a leading icon (checkbox glyph vs. calendar) is a presentation
/// decision made in the Today screen, not here.
enum TodayTaskKind {
  fieldGuideReading,
  weeklyChallenge,
  temperamentQuiz,
  event,
}

/// A single row in a household member's "Today" list — either something
/// actionable (field guide reading, weekly challenge) or an informational
/// event on today's calendar (HAWC Night, Frat Night).
class TodayTask {
  const TodayTask({required this.id, required this.label, required this.kind});

  final String id;
  final String label;
  final TodayTaskKind kind;
}
