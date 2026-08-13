/// Adapted from docs/app_concept.md's `Event Frat Night Details` table —
/// present when `Event.type` is `EventType.fratNight`.
class EventFratNightDetails {
  const EventFratNightDetails({
    required this.id,
    required this.eventId,
    required this.fratNightTemplateId,
    required this.chapterId,
  });

  final String id;
  final String eventId;
  final String fratNightTemplateId;

  /// Also present on `Event Attendees Chapter` for the same event — the
  /// schema notes these two must be kept from deviating.
  final String chapterId;
}
