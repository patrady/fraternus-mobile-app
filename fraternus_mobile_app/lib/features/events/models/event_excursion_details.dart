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
}
