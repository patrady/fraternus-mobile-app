/// Adapted from docs/app_concept.md's `Event Ranch Details` table —
/// present when `Event.type` is `EventType.ranch`.
class EventRanchDetails {
  const EventRanchDetails({required this.id, required this.eventId, required this.registrationUrl});

  final String id;
  final String eventId;
  final String registrationUrl;

  /// `registration_url` is nullable in the schema; the UI doesn't read this
  /// field yet, so an absent value just becomes an empty string rather than
  /// widening this to `String?`.
  factory EventRanchDetails.fromJson(Map<String, dynamic> json) {
    return EventRanchDetails(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      registrationUrl: json['registration_url'] as String? ?? '',
    );
  }
}
