import 'field_guide_daily_devotional.dart';
import 'field_guide_week_quote.dart';

/// One week's Field Guide content — schema's "Field Guide Week", plus its
/// quotes and all 7 daily devotionals nested directly on it (the
/// repository performs this join, same composition choice
/// `WeeklyChallenge.progress` already makes in the Challenge feature).
///
/// The 8 per-temperament Application/Vices fields live here, not on a
/// separate static-content file — they're per-week per the schema, so
/// temperament card copy varies by virtue.
class FieldGuideWeek {
  const FieldGuideWeek({
    required this.id,
    required this.startDate,
    required this.yearNumber,
    required this.weekNumber,
    required this.virtue,
    required this.vice,
    required this.extreme,
    required this.reflection,
    required this.cholericApplication,
    required this.cholericVices,
    required this.sanguineApplication,
    required this.sanguineVices,
    required this.melancholicApplication,
    required this.melancholicVices,
    required this.phlegmaticApplication,
    required this.phlegmaticVices,
    required this.quotes,
    required this.devotionals,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;

  /// The calendar date this week's Frat Night Event actually started —
  /// anchors day_number 1 (a Frat Night can fall on any weekday, so this
  /// is never assumed to be a Monday). [devotionalForDate] computes a
  /// date's day_number as its offset from this date, matching the
  /// `get_field_guide_streak`/`get_field_guide_devotional_for_date` RPCs'
  /// own algorithm (see the field_guide_frat_night_rpcs migration) —
  /// resolving it any other way (e.g. off the date's own weekday) would
  /// silently desync from what those RPCs count as "day N" the moment a
  /// chapter's Frat Night isn't on a Monday.
  final DateTime startDate;

  /// Which program year this week's content belongs to — organizational
  /// metadata only; [devotionalForDate]/the repository's lookup algorithm
  /// key off [weekNumber] alone, which stays globally unique.
  final int yearNumber;
  final int weekNumber;
  final String virtue;
  final String vice;
  final String extreme;

  /// Markdown-enabled per the schema — rendered via `flutter_markdown_plus`.
  final String reflection;

  final String cholericApplication;
  final String cholericVices;
  final String sanguineApplication;
  final String sanguineVices;
  final String melancholicApplication;
  final String melancholicVices;
  final String phlegmaticApplication;
  final String phlegmaticVices;

  final List<FieldGuideWeekQuote> quotes;
  final List<FieldGuideDailyDevotional> devotionals;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  FieldGuideDailyDevotional? devotionalForDate(DateTime date) {
    final dayNumber =
        DateTime(date.year, date.month, date.day)
            .difference(
              DateTime(startDate.year, startDate.month, startDate.day),
            )
            .inDays +
        1;
    for (final devotional in devotionals) {
      if (devotional.dayNumber == dayNumber) return devotional;
    }
    return null;
  }

  String applicationFor(String temperamentKey) => switch (temperamentKey) {
    'choleric' => cholericApplication,
    'sanguine' => sanguineApplication,
    'melancholic' => melancholicApplication,
    'phlegmatic' => phlegmaticApplication,
    _ => throw ArgumentError('Unknown temperament key: $temperamentKey'),
  };

  String vicesFor(String temperamentKey) => switch (temperamentKey) {
    'choleric' => cholericVices,
    'sanguine' => sanguineVices,
    'melancholic' => melancholicVices,
    'phlegmatic' => phlegmaticVices,
    _ => throw ArgumentError('Unknown temperament key: $temperamentKey'),
  };

  /// Expects the nested-embed shape SupabaseGuideRepository queries with:
  /// `field_guide_week_quotes` and `field_guide_daily_devotionals` (each
  /// devotional itself carrying `field_guide_daily_devotional_members`).
  /// [startDate] isn't part of that row — a Field Guide Week's content is
  /// reused across chapters/years, so its anchor date has to come from
  /// whichever Frat Night Event resolved this week for the caller (see
  /// SupabaseGuideRepository.fetchWeekForDate).
  factory FieldGuideWeek.fromJson(
    Map<String, dynamic> json, {
    required DateTime startDate,
  }) {
    final quotesJson =
        json['field_guide_week_quotes'] as List<dynamic>? ?? const [];
    final devotionalsJson =
        json['field_guide_daily_devotionals'] as List<dynamic>? ?? const [];
    return FieldGuideWeek(
      id: json['id'] as String,
      startDate: startDate,
      yearNumber: json['year_number'] as int,
      weekNumber: json['week_number'] as int,
      virtue: json['virtue'] as String,
      vice: json['vice'] as String,
      extreme: json['extreme'] as String,
      reflection: json['reflection'] as String,
      cholericApplication: json['choleric_application'] as String,
      cholericVices: json['choleric_vices'] as String,
      sanguineApplication: json['sanguine_application'] as String,
      sanguineVices: json['sanguine_vices'] as String,
      melancholicApplication: json['melancholic_application'] as String,
      melancholicVices: json['melancholic_vices'] as String,
      phlegmaticApplication: json['phlegmatic_application'] as String,
      phlegmaticVices: json['phlegmatic_vices'] as String,
      quotes: [
        for (final quoteJson in quotesJson)
          FieldGuideWeekQuote.fromJson(quoteJson as Map<String, dynamic>),
      ],
      devotionals: [
        for (final devotionalJson in devotionalsJson)
          FieldGuideDailyDevotional.fromJson(
            devotionalJson as Map<String, dynamic>,
          ),
      ],
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
