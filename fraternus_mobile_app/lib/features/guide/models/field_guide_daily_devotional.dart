import 'field_guide_daily_devotional_member.dart';

/// One day's reading content — schema's "Field Guide Daily Devotional".
/// "Spade" (the prompt text) is named [spadePrompt] here to disambiguate it
/// from each member's own free-text answer in
/// [FieldGuideDailyDevotionalMember.spade].
class FieldGuideDailyDevotional {
  const FieldGuideDailyDevotional({
    required this.id,
    required this.fieldGuideWeekId,
    required this.dayNumber,
    required this.identityReading,
    required this.wisdomQuote,
    required this.wisdomAuthor,
    required this.swordOption1,
    required this.swordOption2,
    required this.spadePrompt,
    required this.closingPrayer,
    required this.closingPrayerAuthor,
    required this.members,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String fieldGuideWeekId;

  /// 1–7, matching [DateTime.weekday] (Monday = 1 .. Sunday = 7).
  final int dayNumber;
  final String identityReading;
  final String wisdomQuote;
  final String wisdomAuthor;

  /// Always exactly two options per the schema — kept as two named fields
  /// rather than a list.
  final String swordOption1;
  final String swordOption2;
  final String spadePrompt;
  final String closingPrayer;
  final String closingPrayerAuthor;
  final List<FieldGuideDailyDevotionalMember> members;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  /// UI convenience for widgets that render a generic option list.
  List<String> get swordOptions => [swordOption1, swordOption2];

  /// [json]'s `field_guide_daily_devotional_members` key is populated when
  /// fetched via a PostgREST nested-embed query (see
  /// SupabaseGuideRepository) — absent (defaults to empty) for a plain
  /// non-embedded row.
  factory FieldGuideDailyDevotional.fromJson(Map<String, dynamic> json) {
    final membersJson =
        json['field_guide_daily_devotional_members'] as List<dynamic>? ??
        const [];
    return FieldGuideDailyDevotional(
      id: json['id'] as String,
      fieldGuideWeekId: json['field_guide_week_id'] as String,
      dayNumber: json['day_number'] as int,
      identityReading: json['identity_reading'] as String,
      wisdomQuote: json['wisdom_quote'] as String,
      wisdomAuthor: json['wisdom_author'] as String,
      swordOption1: json['sword_option_1'] as String,
      swordOption2: json['sword_option_2'] as String,
      spadePrompt: json['spade_prompt'] as String,
      closingPrayer: json['closing_prayer'] as String,
      closingPrayerAuthor: json['closing_prayer_author'] as String,
      members: [
        for (final memberJson in membersJson)
          FieldGuideDailyDevotionalMember.fromJson(
            memberJson as Map<String, dynamic>,
          ),
      ],
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
