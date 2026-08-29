import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../design_system/design_system.dart' show RsvpStatus;
import '../models/event.dart';
import '../models/event_attendee.dart';
import '../models/event_attendees_chapter.dart';
import '../models/event_eligible_member.dart';
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
  /// [memberLabels] (household member id -> display name) resolves both
  /// [Event.eligibleHouseholdMembers]' labels and which of the caller's own
  /// members to check eligibility for — same shape as
  /// `ChallengeRepository.fetchChallenges`' own [memberLabels] param.
  Future<List<Event>> fetchEvents({required DateTime asOf, required Map<String, String> memberLabels});

  /// Submits [memberId]'s RSVP, or clears it back to unanswered if
  /// re-selecting the status they already have (see [HouseholdRsvp]'s "no
  /// row until submitted" rule) — mirrors
  /// `ChallengeRepository.toggleChallengeRep`'s upsert/delete-toggle shape.
  /// Returns the new row, or null if this call cleared it.
  Future<HouseholdRsvp?> submitRsvp({required String eventId, required String memberId, required RsvpStatus status});
}

/// Hardcoded stand-in for real content, matching
/// `design_handoff_components/screenshots/04-events-list.png` and
/// `05-event-detail-rsvp.png`.
///
/// Every timestamp is an offset from [asOf] rather than a literal date —
/// the "visible until 12h after it ends" rule means literal past dates
/// would filter this seed data out entirely the moment it's run on any day
/// after it was written. [submitRsvp] actually mutates this instance's
/// [_rsvps] map, same reasoning as StaticChallengeRepository's `_progress`
/// map — needed so EventRsvp's write-then-invalidate pattern (see
/// events_providers.dart) has something real to show on the next fetch.
/// [memberLabels] is accepted (interface parity) but not used to build
/// [Event.eligibleHouseholdMembers] — this fake's per-event eligibility is
/// fixed seed data, not derived from a real household.
class StaticEventsRepository implements EventsRepository {
  StaticEventsRepository() : _rsvps = _seedRsvps();

  static const _chapterKey = 'st_philips_franklin_franklin_tn';
  static const _submittedByUserId = 'user-john';

  /// Keyed by '$eventId:$memberId'.
  final Map<String, RsvpStatus> _rsvps;

  static Map<String, RsvpStatus> _seedRsvps() => {
    'captain-meeting:you': RsvpStatus.yes,
    'excursion-buffalo-river:jack': RsvpStatus.yes,
    'excursion-buffalo-river:thomas': RsvpStatus.yes,
  };

  List<HouseholdRsvp> _rsvpsFor(String eventId, DateTime asOf) {
    return [
      for (final entry in _rsvps.entries)
        if (entry.key.split(':') case [final eId, final memberId] when eId == eventId)
          HouseholdRsvp(
            id: 'rsvp-${entry.key}',
            eventId: eventId,
            memberId: memberId,
            submittedByUserId: _submittedByUserId,
            status: entry.value,
            createdAt: asOf.subtract(const Duration(days: 9)),
            lastModifiedAt: asOf.subtract(const Duration(days: 9)),
          ),
    ];
  }

  static const _wholeHousehold = [
    EventEligibleMember(memberId: 'you', label: 'Michael (You)'),
    EventEligibleMember(memberId: 'jack', label: 'Jack'),
    EventEligibleMember(memberId: 'thomas', label: 'Thomas'),
  ];

  static const _captainsOnlyHousehold = [
    EventEligibleMember(memberId: 'you', label: 'Michael (You)'),
  ];

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
      chapterKey: _chapterKey,
      role: EventAttendeeChapterRole.chapter,
    ),
  ];

  static List<EventAttendeesChapter> _captainsOnlyFor(String eventId) => [
    EventAttendeesChapter(
      id: 'attendees-captains-$eventId',
      eventId: eventId,
      chapterKey: _chapterKey,
      role: EventAttendeeChapterRole.captains,
    ),
  ];

  @override
  Future<List<Event>> fetchEvents({required DateTime asOf, required Map<String, String> memberLabels}) async {
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
        eligibleHouseholdMembers: _captainsOnlyHousehold,
        householdRsvps: _rsvpsFor('captain-meeting', asOf),
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
        eligibleHouseholdMembers: _wholeHousehold,
        // No one has responded yet — no Event RSVP rows exist.
        householdRsvps: const [],
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
          fratNightTemplateKey: 'fortitude-week',
          chapterKey: _chapterKey,
        ),
        eligibleHouseholdMembers: _wholeHousehold,
        householdRsvps: const [],
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
          hostChapterKey: _chapterKey,
          registrationUrl: 'https://example.com/register/buffalo-river',
        ),
        eligibleHouseholdMembers: _wholeHousehold,
        // "You" hasn't responded yet — only Jack and Thomas have rows.
        householdRsvps: _rsvpsFor('excursion-buffalo-river', asOf),
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
        eligibleHouseholdMembers: _wholeHousehold,
        householdRsvps: const [],
        othersAttending: _othersB,
      ),
    ];
  }

  @override
  Future<HouseholdRsvp?> submitRsvp({
    required String eventId,
    required String memberId,
    required RsvpStatus status,
  }) async {
    final key = '$eventId:$memberId';
    if (_rsvps[key] == status) {
      _rsvps.remove(key);
      return null;
    }
    _rsvps[key] = status;
    final now = DateTime.now();
    return HouseholdRsvp(
      id: 'rsvp-$key',
      eventId: eventId,
      memberId: memberId,
      submittedByUserId: _submittedByUserId,
      status: status,
      createdAt: now,
      lastModifiedAt: now,
    );
  }
}

/// Supabase-backed implementation. RLS (see supabase/migrations) enforces
/// that the caller can only read/write RSVPs for Members they have a Self
/// or Guardian association with.
class SupabaseEventsRepository implements EventsRepository {
  SupabaseEventsRepository(this._client);

  final SupabaseClient _client;

  @override
  Future<List<Event>> fetchEvents({required DateTime asOf, required Map<String, String> memberLabels}) async {
    final rows = await _client
        .from('events')
        .select(
          '*, event_frat_night_details(*), event_excursion_details(*), event_ranch_details(*), '
          'event_attendees_chapter(*), event_attendees_specific(*), event_rsvps(*)',
        );

    final memberIds = memberLabels.keys.toList();
    return Future.wait([
      for (final row in rows) _hydrate(row, memberIds: memberIds, memberLabels: memberLabels),
    ]);
  }

  /// Resolves per-event eligibility and "Others Attending" via their own
  /// RPC calls (see get_event_eligible_members/get_event_attendees) rather
  /// than nested embeds — neither is a plain stored-row read: eligibility is
  /// a chapter-role-rules-vs-specific-invites computation, and attendees is
  /// a deliberately cross-household read that `event_rsvps`' own RLS
  /// wouldn't allow through a normal embed.
  Future<Event> _hydrate(
    Map<String, dynamic> row, {
    required List<String> memberIds,
    required Map<String, String> memberLabels,
  }) async {
    final eventId = row['id'];

    final attendeesRows = await _client.rpc('get_event_attendees', params: {'p_event_id': eventId});
    final othersAttending = [
      for (final r in attendeesRows as List<dynamic>) EventAttendee.fromJson(r as Map<String, dynamic>),
    ];

    if (memberIds.isEmpty) {
      return Event.fromJson(
        row,
        memberLabels: memberLabels,
        eligibleMemberIds: const [],
        othersAttending: othersAttending,
      );
    }
    final eligible = await _client.rpc(
      'get_event_eligible_members',
      params: {'p_event_id': eventId, 'p_member_ids': memberIds},
    );
    final eligibleIds = [for (final r in eligible as List<dynamic>) (r as Map<String, dynamic>)['member_id'] as String];
    return Event.fromJson(
      row,
      memberLabels: memberLabels,
      eligibleMemberIds: eligibleIds,
      othersAttending: othersAttending,
    );
  }

  @override
  Future<HouseholdRsvp?> submitRsvp({
    required String eventId,
    required String memberId,
    required RsvpStatus status,
  }) async {
    final result = await _client.rpc(
      'submit_event_rsvp',
      params: {'p_event_id': eventId, 'p_member_id': memberId, 'p_response': HouseholdRsvp.statusToDb(status)},
    );
    if (result == null) return null;
    final row = result as Map<String, dynamic>;
    if (row['id'] == null) return null; // un-toggled — the RPC returns an all-null row, not absent
    return HouseholdRsvp.fromJson(row);
  }
}
