import '../../../design_system/design_system.dart' show RsvpStatus;
import '../models/event.dart';
import '../models/event_attendee.dart';
import '../models/event_attendees_chapter.dart';
import '../models/event_excursion_details.dart';
import '../models/event_frat_night_details.dart';
import '../models/event_ranch_details.dart';
import '../models/household_rsvp.dart';

/// Source of the chapter's events. Returning a [Future] here — even though
/// [StaticEventsRepository] resolves instantly — is the deliberate seam:
/// swapping to a Drift-backed `Stream` query or a real API call later only
/// means changing the implementation, not this interface, the providers
/// that watch it, or the screens.
abstract class EventsRepository {
  Future<List<Event>> fetchEvents({required DateTime asOf});
}

/// Hardcoded stand-in for real content, matching
/// `design_handoff_components/screenshots/04-events-list.png` and
/// `05-event-detail-rsvp.png`.
///
/// Every timestamp is an offset from [asOf] rather than a literal date —
/// the "visible until 12h after it ends" rule means literal past dates
/// would filter this seed data out entirely the moment it's run on any day
/// after it was written.
class StaticEventsRepository implements EventsRepository {
  const StaticEventsRepository();

  static const _chapterId = 'st-philips-franklin';

  static const _othersA = [
    EventAttendee(id: 'mark-delaney', name: 'Mark Delaney'),
    EventAttendee(id: 'peter-vance', name: 'Peter Vance'),
    EventAttendee(id: 'luke-torres', name: 'Luke Torres'),
    EventAttendee(id: 'andrew-kim', name: 'Andrew Kim'),
  ];

  static const _othersB = [
    EventAttendee(id: 'mark-delaney', name: 'Mark Delaney'),
    EventAttendee(id: 'peter-vance', name: 'Peter Vance'),
    EventAttendee(id: 'luke-torres', name: 'Luke Torres'),
    EventAttendee(id: 'andrew-kim', name: 'Andrew Kim'),
    EventAttendee(id: 'simon-kowalski', name: 'Simon Kowalski'),
  ];

  static List<EventAttendeesChapter> _entireChapterFor(String eventId) => [
    EventAttendeesChapter(
      id: 'attendees-chapter-$eventId',
      eventId: eventId,
      chapterId: _chapterId,
      role: EventAttendeeChapterRole.chapter,
    ),
  ];

  static List<EventAttendeesChapter> _captainsOnlyFor(String eventId) => [
    EventAttendeesChapter(
      id: 'attendees-captains-$eventId',
      eventId: eventId,
      chapterId: _chapterId,
      role: EventAttendeeChapterRole.captains,
    ),
  ];

  @override
  Future<List<Event>> fetchEvents({required DateTime asOf}) async {
    return [
      Event(
        id: 'captain-meeting',
        type: EventType.custom,
        title: 'Captain Meeting',
        description: 'Planning meeting for the fall semester schedule.',
        location: 'St. Philips - Parish Hall',
        startAt: asOf.subtract(const Duration(hours: 5, minutes: 30)),
        endAt: asOf.subtract(const Duration(hours: 5)),
        cancellationDate: asOf.subtract(const Duration(days: 1)),
        createdAt: asOf.subtract(const Duration(days: 10)),
        lastModifiedAt: asOf.subtract(const Duration(days: 1)),
        attendeesChapter: _captainsOnlyFor('captain-meeting'),
        attendeesSpecific: const [],
        householdRsvps: [
          HouseholdRsvp(
            id: 'rsvp-captain-meeting-you',
            eventId: 'captain-meeting',
            memberId: 'you',
            label: 'Michael (You)',
            status: RsvpStatus.yes,
            createdAt: asOf.subtract(const Duration(days: 9)),
            lastModifiedAt: asOf.subtract(const Duration(days: 9)),
          ),
        ],
        othersAttending: _othersA,
      ),
      Event(
        id: 'hawc-night',
        type: EventType.custom,
        title: 'HAWC Night',
        description: 'Holy Hour, Adoration, Worship, and Confession for fathers and captains.',
        location: 'St. Philips - Youth Room',
        startAt: asOf.add(const Duration(minutes: 30)),
        endAt: asOf.add(const Duration(hours: 2)),
        createdAt: asOf.subtract(const Duration(days: 10)),
        lastModifiedAt: asOf.subtract(const Duration(days: 10)),
        attendeesChapter: _entireChapterFor('hawc-night'),
        attendeesSpecific: const [],
        householdRsvps: [
          HouseholdRsvp(
            id: 'rsvp-hawc-night-you',
            eventId: 'hawc-night',
            memberId: 'you',
            label: 'Michael (You)',
            createdAt: asOf.subtract(const Duration(days: 9)),
            lastModifiedAt: asOf.subtract(const Duration(days: 9)),
          ),
          HouseholdRsvp(
            id: 'rsvp-hawc-night-jack',
            eventId: 'hawc-night',
            memberId: 'jack',
            label: 'Jack',
            createdAt: asOf.subtract(const Duration(days: 9)),
            lastModifiedAt: asOf.subtract(const Duration(days: 9)),
          ),
          HouseholdRsvp(
            id: 'rsvp-hawc-night-thomas',
            eventId: 'hawc-night',
            memberId: 'thomas',
            label: 'Thomas',
            createdAt: asOf.subtract(const Duration(days: 9)),
            lastModifiedAt: asOf.subtract(const Duration(days: 9)),
          ),
        ],
        othersAttending: _othersA,
      ),
      Event(
        id: 'frat-night',
        type: EventType.fratNight,
        title: 'Frat Night — Virtue of Fortitude',
        description: 'Fellowship, formation talk, and games centered on the virtue of fortitude.',
        location: 'St. Philips - Parish Hall',
        startAt: asOf.add(const Duration(hours: 2)),
        endAt: asOf.add(const Duration(hours: 4)),
        createdAt: asOf.subtract(const Duration(days: 10)),
        lastModifiedAt: asOf.subtract(const Duration(days: 10)),
        attendeesChapter: _entireChapterFor('frat-night'),
        attendeesSpecific: const [],
        fratNightDetails: const EventFratNightDetails(
          id: 'frat-night-details',
          eventId: 'frat-night',
          fratNightTemplateId: 'fortitude-week',
          chapterId: _chapterId,
        ),
        householdRsvps: [
          HouseholdRsvp(
            id: 'rsvp-frat-night-you',
            eventId: 'frat-night',
            memberId: 'you',
            label: 'Michael (You)',
            createdAt: asOf.subtract(const Duration(days: 9)),
            lastModifiedAt: asOf.subtract(const Duration(days: 9)),
          ),
          HouseholdRsvp(
            id: 'rsvp-frat-night-jack',
            eventId: 'frat-night',
            memberId: 'jack',
            label: 'Jack',
            createdAt: asOf.subtract(const Duration(days: 9)),
            lastModifiedAt: asOf.subtract(const Duration(days: 9)),
          ),
          HouseholdRsvp(
            id: 'rsvp-frat-night-thomas',
            eventId: 'frat-night',
            memberId: 'thomas',
            label: 'Thomas',
            createdAt: asOf.subtract(const Duration(days: 9)),
            lastModifiedAt: asOf.subtract(const Duration(days: 9)),
          ),
        ],
        othersAttending: _othersA,
      ),
      Event(
        id: 'excursion-buffalo-river',
        type: EventType.excursion,
        title: 'Excursion - Buffalo River',
        description: 'Full-day canoe excursion. Bring water shoes and a change of clothes.',
        location: 'Buffalo River',
        startAt: asOf.add(const Duration(days: 12, hours: 9)),
        endAt: asOf.add(const Duration(days: 12, hours: 19)),
        createdAt: asOf.subtract(const Duration(days: 20)),
        lastModifiedAt: asOf.subtract(const Duration(days: 20)),
        attendeesChapter: _entireChapterFor('excursion-buffalo-river'),
        attendeesSpecific: const [],
        excursionDetails: const EventExcursionDetails(
          id: 'excursion-buffalo-river-details',
          eventId: 'excursion-buffalo-river',
          hostChapterId: _chapterId,
          registrationUrl: 'https://example.com/register/buffalo-river',
        ),
        householdRsvps: [
          HouseholdRsvp(
            id: 'rsvp-buffalo-river-you',
            eventId: 'excursion-buffalo-river',
            memberId: 'you',
            label: 'Michael (You)',
            createdAt: asOf.subtract(const Duration(days: 19)),
            lastModifiedAt: asOf.subtract(const Duration(days: 19)),
          ),
          HouseholdRsvp(
            id: 'rsvp-buffalo-river-jack',
            eventId: 'excursion-buffalo-river',
            memberId: 'jack',
            label: 'Jack',
            status: RsvpStatus.yes,
            createdAt: asOf.subtract(const Duration(days: 19)),
            lastModifiedAt: asOf.subtract(const Duration(days: 19)),
          ),
          HouseholdRsvp(
            id: 'rsvp-buffalo-river-thomas',
            eventId: 'excursion-buffalo-river',
            memberId: 'thomas',
            label: 'Thomas',
            status: RsvpStatus.yes,
            createdAt: asOf.subtract(const Duration(days: 19)),
            lastModifiedAt: asOf.subtract(const Duration(days: 19)),
          ),
        ],
        othersAttending: _othersB,
      ),
      Event(
        id: 'ranch',
        type: EventType.ranch,
        title: 'Ranch',
        description: 'Multi-day retreat at the ranch — bring gear for both hiking and rain.',
        location: 'Old Fort, Tennessee',
        startAt: asOf.add(const Duration(days: 20, hours: 9)),
        endAt: asOf.add(const Duration(days: 24, hours: 15)),
        createdAt: asOf.subtract(const Duration(days: 30)),
        lastModifiedAt: asOf.subtract(const Duration(days: 30)),
        attendeesChapter: _entireChapterFor('ranch'),
        attendeesSpecific: const [],
        ranchDetails: const EventRanchDetails(
          id: 'ranch-details',
          eventId: 'ranch',
          registrationUrl: 'https://example.com/register/ranch',
        ),
        householdRsvps: [
          HouseholdRsvp(
            id: 'rsvp-ranch-you',
            eventId: 'ranch',
            memberId: 'you',
            label: 'Michael (You)',
            createdAt: asOf.subtract(const Duration(days: 29)),
            lastModifiedAt: asOf.subtract(const Duration(days: 29)),
          ),
          HouseholdRsvp(
            id: 'rsvp-ranch-jack',
            eventId: 'ranch',
            memberId: 'jack',
            label: 'Jack',
            createdAt: asOf.subtract(const Duration(days: 29)),
            lastModifiedAt: asOf.subtract(const Duration(days: 29)),
          ),
          HouseholdRsvp(
            id: 'rsvp-ranch-thomas',
            eventId: 'ranch',
            memberId: 'thomas',
            label: 'Thomas',
            createdAt: asOf.subtract(const Duration(days: 29)),
            lastModifiedAt: asOf.subtract(const Duration(days: 29)),
          ),
        ],
        othersAttending: _othersB,
      ),
    ];
  }
}
