/// Adapted from docs/app_concept.md's `Event Attendees Specific` table —
/// declares that one specific Member (identified by email at invite time)
/// is eligible for an event, independent of chapter-wide eligibility.
class EventAttendeesSpecific {
  const EventAttendeesSpecific({required this.id, required this.eventId, required this.memberId});

  final String id;
  final String eventId;
  final String memberId;

  factory EventAttendeesSpecific.fromJson(Map<String, dynamic> json) {
    return EventAttendeesSpecific(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      memberId: json['member_id'] as String,
    );
  }
}
