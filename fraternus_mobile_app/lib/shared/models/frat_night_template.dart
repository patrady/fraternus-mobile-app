import 'frat_night_virtue.dart';

/// Adapted from docs/app_concept.md's `Frat Night Template` table — the
/// content seeded for a given calendar week of Frat Night. Shared (not
/// feature-local) since both Events (`Event Frat Night Details`) and
/// Challenges (`Challenge.fratNightTemplateId`, 1:1) reference it.
///
/// [virtue] is nested here as a read-model convenience (same join-and-nest
/// pattern as `FieldGuideWeek.quotes`/`devotionals`), resolved from
/// [fratNightVirtueId].
class FratNightTemplate {
  const FratNightTemplate({
    required this.id,
    required this.title,
    required this.description,
    required this.reading,
    required this.liturgicalDay,
    required this.startOfWeekDate,
    required this.fratNightVirtueId,
    required this.virtue,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String title;
  final String description;

  /// Markdown-enabled per the schema.
  final String reading;

  /// e.g. "First Sunday in Ordinary Time".
  final String liturgicalDay;

  /// e.g. 2026-01-01. Unique per the schema — drives both which week's
  /// Challenge is "current" and which week's Frat Night reading is shown.
  final DateTime startOfWeekDate;
  final String fratNightVirtueId;
  final FratNightVirtue virtue;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  /// Expects the nested-embed shape (`frat_night_virtues(*)`) — see
  /// SupabaseChallengeRepository.
  factory FratNightTemplate.fromJson(Map<String, dynamic> json) {
    return FratNightTemplate(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      reading: json['reading'] as String,
      liturgicalDay: json['liturgical_day'] as String,
      startOfWeekDate: DateTime.parse(json['start_of_week_date'] as String),
      fratNightVirtueId: json['frat_night_virtue_id'] as String,
      virtue: FratNightVirtue.fromJson(json['frat_night_virtues'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
