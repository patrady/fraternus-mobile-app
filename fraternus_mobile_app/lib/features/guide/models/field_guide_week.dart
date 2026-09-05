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
    for (final devotional in devotionals) {
      if (devotional.dayNumber == date.weekday) return devotional;
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
  factory FieldGuideWeek.fromJson(Map<String, dynamic> json) {
    final quotesJson =
        json['field_guide_week_quotes'] as List<dynamic>? ?? const [];
    final devotionalsJson =
        json['field_guide_daily_devotionals'] as List<dynamic>? ?? const [];
    return FieldGuideWeek(
      id: json['id'] as String,
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
