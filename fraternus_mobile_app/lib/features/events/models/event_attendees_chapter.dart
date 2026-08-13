/// Adapted from docs/app_concept.md's `Event Attendees Chapter` table —
/// declares that a whole chapter-level group (Captains, Brothers, or the
/// full Chapter) is eligible for an event.
enum EventAttendeeChapterRole { captains, brothers, chapter }

class EventAttendeesChapter {
  const EventAttendeesChapter({required this.id, required this.eventId, required this.chapterId, required this.role});

  final String id;
  final String eventId;
  final String chapterId;
  final EventAttendeeChapterRole role;
}
