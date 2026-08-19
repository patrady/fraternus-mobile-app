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

  factory EventAttendeesChapter.fromJson(Map<String, dynamic> json) {
    return EventAttendeesChapter(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      chapterId: json['chapter_id'] as String,
      role: EventAttendeeChapterRole.values.byName(json['role'] as String),
    );
  }
}
