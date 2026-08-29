/// Adapted from docs/app_concept.md's `Frat Night Template` table — the
/// content seeded for a given calendar week of Frat Night. Shared (not
/// feature-local) since both Events (`Event Frat Night Details`) and
/// Challenges (`Challenge.fratNightTemplateKey`, 1:1) reference it — by
/// [key], not [id] (see the frat_night_template_fk_use_key migration).
///
/// Has no date of its own — a template's effective date is whichever
/// Event actually references it (`event_frat_night_details` ->
/// `events.start_date`), not a separately hardcoded field. See
/// `WeeklyChallenge.fratNightDate`.
class FratNightTemplate {
  const FratNightTemplate({
    required this.id,
    required this.key,
    required this.title,
    required this.description,
    required this.reading,
    required this.createdAt,
    required this.lastModifiedAt,
    this.videoClipUrl,
  });

  final String id;

  /// Stable natural key, distinct from [id] — what Challenges and Event
  /// Frat Night Details actually reference.
  final String key;
  final String title;
  final String description;

  /// Markdown-enabled per the schema.
  final String reading;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  /// Optional — not every template has an accompanying video clip.
  final String? videoClipUrl;

  factory FratNightTemplate.fromJson(Map<String, dynamic> json) {
    return FratNightTemplate(
      id: json['id'] as String,
      key: json['key'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      reading: json['reading'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['updated_at'] as String),
      videoClipUrl: json['video_clip_url'] as String?,
    );
  }
}
