import 'field_guide_daily_devotional_member.dart';

/// One day's reading content — schema's "Field Guide Daily Devotional".
/// "Sword Option 1/2" combine into [swordOptions]; "Spade" (the prompt
/// text) is named [spadePrompt] here to disambiguate it from each member's
/// own free-text answer in [FieldGuideDailyDevotionalMember.spade].
class FieldGuideDailyDevotional {
  const FieldGuideDailyDevotional({
    required this.id,
    required this.fieldGuideWeekId,
    required this.dayNumber,
    required this.identityReading,
    required this.wisdomQuote,
    required this.wisdomAuthor,
    required this.swordOptions,
    required this.spadePrompt,
    required this.closingPrayer,
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
  final List<String> swordOptions;
  final String spadePrompt;
  final String closingPrayer;
  final List<FieldGuideDailyDevotionalMember> members;
  final DateTime createdAt;
  final DateTime lastModifiedAt;
}
