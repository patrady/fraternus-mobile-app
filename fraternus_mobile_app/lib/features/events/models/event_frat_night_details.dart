/// Adapted from docs/app_concept.md's `Event Frat Night Details` table —
/// present when `Event.type` is `EventType.fratNight`.
class EventFratNightDetails {
  const EventFratNightDetails({
    required this.id,
    required this.eventId,
    required this.fratNightTemplateKey,
    required this.chapterKey,
  });

  final String id;
  final String eventId;
  final String fratNightTemplateKey;

  /// Also present on `Event Attendees Chapter` for the same event — the
  /// schema notes these two must be kept from deviating.
  final String chapterKey;

  factory EventFratNightDetails.fromJson(Map<String, dynamic> json) {
    return EventFratNightDetails(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      fratNightTemplateKey: json['frat_night_template_key'] as String,
      chapterKey: json['chapter_key'] as String,
    );
  }
}
