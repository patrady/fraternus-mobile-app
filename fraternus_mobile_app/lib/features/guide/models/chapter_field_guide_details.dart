/// Adapted from docs/app_concept.md's `Chapter Field Guide Details` table —
/// one row per chapter per school year, anchoring the devotional-selection
/// algorithm (see `GuideRepository.fetchWeekForDate`).
class ChapterFieldGuideDetails {
  const ChapterFieldGuideDetails({
    required this.id,
    required this.chapterId,
    required this.schoolYearStartDate,
    required this.schoolYearEndDate,
    required this.fieldGuideStartDate,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String chapterId;
  final DateTime schoolYearStartDate;
  final DateTime schoolYearEndDate;

  /// Day 0 of Week 0, Day 1 — every Field Guide Week/Day Number is computed
  /// as an offset from this date.
  final DateTime fieldGuideStartDate;
  final DateTime createdAt;
  final DateTime lastModifiedAt;
}
