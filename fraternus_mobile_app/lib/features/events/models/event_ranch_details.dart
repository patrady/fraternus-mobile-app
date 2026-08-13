/// Adapted from docs/app_concept.md's `Event Ranch Details` table —
/// present when `Event.type` is `EventType.ranch`.
class EventRanchDetails {
  const EventRanchDetails({required this.id, required this.eventId, required this.registrationUrl});

  final String id;
  final String eventId;
  final String registrationUrl;
}
