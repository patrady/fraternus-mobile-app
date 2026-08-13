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
}
