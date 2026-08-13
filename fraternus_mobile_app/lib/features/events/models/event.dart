import 'event_attendee.dart';
import 'event_attendees_chapter.dart';
import 'event_attendees_specific.dart';
import 'event_excursion_details.dart';
import 'event_frat_night_details.dart';
import 'event_ranch_details.dart';
import 'household_rsvp.dart';

enum EventType { fratNight, excursion, ranch, custom }

/// A single chapter event — richer than `today/models/event_summary.dart`'s
/// `EventSummary`, which is deliberately thin and stays scoped to the Today
/// dashboard's own preview list.
class Event {
  const Event({
    required this.id,
    required this.type,
    required this.title,
    this.description,
    this.location,
    required this.startAt,
    required this.endAt,
    this.cancellationDate,
    required this.createdAt,
    required this.lastModifiedAt,
    required this.attendeesChapter,
    required this.attendeesSpecific,
    this.fratNightDetails,
    this.excursionDetails,
    this.ranchDetails,
    required this.householdRsvps,
    required this.othersAttending,
  });

  final String id;
  final EventType type;
  final String title;
  final String? description;
  final String? location;
  final DateTime startAt;
  final DateTime endAt;
  final DateTime? cancellationDate;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  /// Chapter-wide eligibility rows (Captains / Brothers / entire Chapter) —
  /// schema's `Event Attendees Chapter`.
  final List<EventAttendeesChapter> attendeesChapter;

  /// Individually-invited eligibility rows — schema's
  /// `Event Attendees Specific`.
  final List<EventAttendeesSpecific> attendeesSpecific;

  /// Populated only when [type] is [EventType.fratNight].
  final EventFratNightDetails? fratNightDetails;

  /// Populated only when [type] is [EventType.excursion].
  final EventExcursionDetails? excursionDetails;

  /// Populated only when [type] is [EventType.ranch].
  final EventRanchDetails? ranchDetails;

  final List<HouseholdRsvp> householdRsvps;
  final List<EventAttendee> othersAttending;

  /// The UI only needs cancelled-or-not, not when it was cancelled.
  bool get isCancelled => cancellationDate != null;
}
