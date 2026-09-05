import 'field_guide_week_quote_member.dart';

class FieldGuideWeekQuote {
  const FieldGuideWeekQuote({
    required this.id,
    required this.fieldGuideWeekId,
    required this.quote,
    required this.author,
    this.members = const [],
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String fieldGuideWeekId;
  final String quote;
  final String author;
  final List<FieldGuideWeekQuoteMember> members;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  bool isFavoriteFor(String memberId) {
    for (final member in members) {
      if (member.memberId == memberId) return member.isFavorite;
    }
    return false;
  }

  /// [json]'s `field_guide_week_quotes_members` key is populated when
  /// fetched via a PostgREST nested-embed query (see
  /// SupabaseGuideRepository) — absent (defaults to empty) for a plain
  /// non-embedded row.
  factory FieldGuideWeekQuote.fromJson(Map<String, dynamic> json) {
    final membersJson =
        json['field_guide_week_quotes_members'] as List<dynamic>? ?? const [];
    return FieldGuideWeekQuote(
      id: json['id'] as String,
      fieldGuideWeekId: json['field_guide_week_id'] as String,
      quote: json['quote'] as String,
      author: json['author'] as String,
      members: [
        for (final memberJson in membersJson)
          FieldGuideWeekQuoteMember.fromJson(
            memberJson as Map<String, dynamic>,
          ),
      ],
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
