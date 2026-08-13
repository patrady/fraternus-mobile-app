import 'event_attendee.dart';
import 'household_rsvp.dart';

enum EventScope { entireChapter, captainsOnly }

enum EventStatus { scheduled, cancelled }

/// A single chapter event — richer than `today/models/event_summary.dart`'s
/// `EventSummary`, which is deliberately thin and stays scoped to the Today
/// dashboard's own preview list.
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.startAt,
    required this.endAt,
    required this.location,
    required this.description,
    required this.scope,
    required this.status,
    required this.householdRsvps,
    required this.othersAttending,
  });

  final String id;
  final String title;
  final DateTime startAt;
  final DateTime endAt;
  final String location;
  final String description;
  final EventScope scope;
  final EventStatus status;
  final List<HouseholdRsvp> householdRsvps;
  final List<EventAttendee> othersAttending;
}
