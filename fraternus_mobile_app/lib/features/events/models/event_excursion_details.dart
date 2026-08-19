/// Adapted from docs/app_concept.md's `Event Excursion Details` table —
/// present when `Event.type` is `EventType.excursion`.
class EventExcursionDetails {
  const EventExcursionDetails({
    required this.id,
    required this.eventId,
    required this.hostChapterId,
    required this.registrationUrl,
  });

  final String id;
  final String eventId;
  final String hostChapterId;
  final String registrationUrl;

  /// `registration_url` is nullable in the schema; the UI doesn't read this
  /// field yet, so an absent value just becomes an empty string rather than
  /// widening this to `String?`.
  factory EventExcursionDetails.fromJson(Map<String, dynamic> json) {
    return EventExcursionDetails(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      hostChapterId: json['host_chapter_id'] as String,
      registrationUrl: json['registration_url'] as String? ?? '',
    );
  }
}
