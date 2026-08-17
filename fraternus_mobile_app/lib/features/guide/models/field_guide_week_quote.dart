class FieldGuideWeekQuote {
  const FieldGuideWeekQuote({
    required this.id,
    required this.fieldGuideWeekId,
    required this.quote,
    required this.author,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String fieldGuideWeekId;
  final String quote;
  final String author;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  factory FieldGuideWeekQuote.fromJson(Map<String, dynamic> json) {
    return FieldGuideWeekQuote(
      id: json['id'] as String,
      fieldGuideWeekId: json['field_guide_week_id'] as String,
      quote: json['quote'] as String,
      author: json['author'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
