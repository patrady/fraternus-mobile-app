/// One household member's favorite state for a single Field Guide Week
/// quote — schema's "Field Guide Week Quotes Member".
class FieldGuideWeekQuoteMember {
  const FieldGuideWeekQuoteMember({
    required this.id,
    required this.fieldGuideWeekQuotesId,
    required this.memberId,
    required this.isFavorite,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String fieldGuideWeekQuotesId;
  final String memberId;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  factory FieldGuideWeekQuoteMember.fromJson(Map<String, dynamic> json) {
    return FieldGuideWeekQuoteMember(
      id: json['id'] as String,
      fieldGuideWeekQuotesId: json['field_guide_week_quotes_id'] as String,
      memberId: json['member_id'] as String,
      isFavorite: json['is_favorite'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
