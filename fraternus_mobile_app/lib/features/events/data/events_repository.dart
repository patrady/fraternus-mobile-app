import '../../../design_system/design_system.dart' show RsvpStatus;
import '../models/event.dart';
import '../models/event_attendee.dart';
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

  static const _othersA = [
    EventAttendee(id: 'mark-delaney', name: 'Mark Delaney', initials: 'MD'),
    EventAttendee(id: 'peter-vance', name: 'Peter Vance', initials: 'PV'),
    EventAttendee(id: 'luke-torres', name: 'Luke Torres', initials: 'LT'),
    EventAttendee(id: 'andrew-kim', name: 'Andrew Kim', initials: 'AK'),
  ];

  static const _othersB = [
    EventAttendee(id: 'mark-delaney', name: 'Mark Delaney', initials: 'MD'),
    EventAttendee(id: 'peter-vance', name: 'Peter Vance', initials: 'PV'),
    EventAttendee(id: 'luke-torres', name: 'Luke Torres', initials: 'LT'),
    EventAttendee(id: 'andrew-kim', name: 'Andrew Kim', initials: 'AK'),
    EventAttendee(id: 'simon-kowalski', name: 'Simon Kowalski', initials: 'SK'),
  ];

  @override
  Future<List<Event>> fetchEvents({required DateTime asOf}) async {
    return [
      Event(
        id: 'captain-meeting',
        title: 'Captain Meeting',
        startAt: asOf.subtract(const Duration(hours: 5, minutes: 30)),
        endAt: asOf.subtract(const Duration(hours: 5)),
        location: 'St. Philips - Parish Hall',
        description: 'Planning meeting for the fall semester schedule.',
        scope: EventScope.captainsOnly,
        status: EventStatus.cancelled,
        householdRsvps: const [
          HouseholdRsvp(personKey: 'you', label: 'Michael (You)', status: RsvpStatus.yes),
        ],
        othersAttending: _othersA,
      ),
      Event(
        id: 'hawc-night',
        title: 'HAWC Night',
        startAt: asOf.add(const Duration(minutes: 30)),
        endAt: asOf.add(const Duration(hours: 2)),
        location: 'St. Philips - Youth Room',
        description: 'Holy Hour, Adoration, Worship, and Confession for fathers and captains.',
        scope: EventScope.entireChapter,
        status: EventStatus.scheduled,
        householdRsvps: const [
          HouseholdRsvp(personKey: 'you', label: 'Michael (You)'),
          HouseholdRsvp(personKey: 'jack', label: 'Jack'),
          HouseholdRsvp(personKey: 'thomas', label: 'Thomas'),
        ],
        othersAttending: _othersA,
      ),
      Event(
        id: 'frat-night',
        title: 'Frat Night — Virtue of Fortitude',
        startAt: asOf.add(const Duration(hours: 2)),
        endAt: asOf.add(const Duration(hours: 4)),
        location: 'St. Philips - Parish Hall',
        description: 'Fellowship, formation talk, and games centered on the virtue of fortitude.',
        scope: EventScope.entireChapter,
        status: EventStatus.scheduled,
        householdRsvps: const [
          HouseholdRsvp(personKey: 'you', label: 'Michael (You)'),
          HouseholdRsvp(personKey: 'jack', label: 'Jack'),
          HouseholdRsvp(personKey: 'thomas', label: 'Thomas'),
        ],
        othersAttending: _othersA,
      ),
      Event(
        id: 'excursion-buffalo-river',
        title: 'Excursion - Buffalo River',
        startAt: asOf.add(const Duration(days: 12, hours: 9)),
        endAt: asOf.add(const Duration(days: 12, hours: 19)),
        location: 'Buffalo River',
        description: 'Full-day canoe excursion. Bring water shoes and a change of clothes.',
        scope: EventScope.entireChapter,
        status: EventStatus.scheduled,
        householdRsvps: const [
          HouseholdRsvp(personKey: 'you', label: 'Michael (You)'),
          HouseholdRsvp(personKey: 'jack', label: 'Jack', status: RsvpStatus.yes),
          HouseholdRsvp(personKey: 'thomas', label: 'Thomas', status: RsvpStatus.yes),
        ],
        othersAttending: _othersB,
      ),
      Event(
        id: 'ranch',
        title: 'Ranch',
        startAt: asOf.add(const Duration(days: 20, hours: 9)),
        endAt: asOf.add(const Duration(days: 24, hours: 15)),
        location: 'Old Fort, Tennessee',
        description: 'Multi-day retreat at the ranch — bring gear for both hiking and rain.',
        scope: EventScope.entireChapter,
        status: EventStatus.scheduled,
        householdRsvps: const [
          HouseholdRsvp(personKey: 'you', label: 'Michael (You)'),
          HouseholdRsvp(personKey: 'jack', label: 'Jack'),
          HouseholdRsvp(personKey: 'thomas', label: 'Thomas'),
        ],
        othersAttending: _othersB,
      ),
    ];
  }
}
