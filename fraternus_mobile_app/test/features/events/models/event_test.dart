import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/events/models/event.dart';
import 'package:fraternus_mobile_app/features/events/models/event_attendee.dart';
import 'package:fraternus_mobile_app/features/events/models/event_kings_messenger.dart';

Map<String, dynamic> _rsvpJson({required String memberId, required String response}) => {
  'id': 'rsvp-$memberId',
  'event_id': 'event-1',
  'member_id': memberId,
  'submitted_by_user_id': 'user-1',
  'response': response,
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
};

Map<String, dynamic> _baseJson({
  String type = 'frat_night',
  String? cancellationDate,
  Map<String, dynamic>? locationJson,
  List<Map<String, dynamic>> rsvps = const [],
}) => {
  'id': 'event-1',
  'type': type,
  'title': 'Frat Night',
  'description': 'Weekly meeting',
  'event_locations': locationJson,
  'start_date': '2026-01-07T19:00:00Z',
  'end_date': '2026-01-07T20:30:00Z',
  'cancellation_date': cancellationDate,
  'created_at': '2026-01-01T00:00:00Z',
  'updated_at': '2026-01-01T00:00:00Z',
  'event_attendees_chapter': const [],
  'event_attendees_specific': const [],
  'event_rsvps': rsvps,
};

void main() {
  group('Event.fromJson', () {
    test('parses a minimal frat-night event with no embeds resolved', () {
      final event = Event.fromJson(
        _baseJson(),
        memberLabels: const {},
        eligibleMemberIds: const [],
        othersAttending: const [],
        kingsMessengers: const [],
      );

      expect(event.type, EventType.fratNight);
      expect(event.location, isNull);
      expect(event.fratNightDetails, isNull);
      expect(event.excursionDetails, isNull);
      expect(event.ranchDetails, isNull);
      expect(event.isCancelled, isFalse);
    });

    test('a non-null cancellation_date marks the event cancelled', () {
      final event = Event.fromJson(
        _baseJson(cancellationDate: '2026-01-05T00:00:00Z'),
        memberLabels: const {},
        eligibleMemberIds: const [],
        othersAttending: const [],
        kingsMessengers: const [],
      );

      expect(event.isCancelled, isTrue);
    });

    test('parses the embedded location when present', () {
      final event = Event.fromJson(
        _baseJson(locationJson: {'id': 'loc-1', 'name': 'Parish Hall'}),
        memberLabels: const {},
        eligibleMemberIds: const [],
        othersAttending: const [],
        kingsMessengers: const [],
      );

      expect(event.location?.name, 'Parish Hall');
    });

    test(
      'resolves eligibleHouseholdMembers from ids + labels, skipping unresolved ids',
      () {
        final event = Event.fromJson(
          _baseJson(),
          memberLabels: {'member-1': 'John Smith'},
          eligibleMemberIds: const ['member-1', 'member-unresolved'],
          othersAttending: const [],
          kingsMessengers: const [],
        );

        expect(event.eligibleHouseholdMembers, hasLength(1));
        expect(event.eligibleHouseholdMembers.single.memberId, 'member-1');
        expect(event.eligibleHouseholdMembers.single.label, 'John Smith');
      },
    );

    test('passes othersAttending through unchanged', () {
      const attendee = EventAttendee(id: 'member-2', name: 'Jane Doe');
      final event = Event.fromJson(
        _baseJson(),
        memberLabels: const {},
        eligibleMemberIds: const [],
        othersAttending: const [attendee],
        kingsMessengers: const [],
      );

      expect(event.othersAttending, [attendee]);
    });

    test('passes kingsMessengers through unchanged', () {
      const messenger = EventKingsMessenger(
        memberId: 'member-3',
        firstName: 'Mark',
        lastName: 'Delaney',
      );
      final event = Event.fromJson(
        _baseJson(),
        memberLabels: const {},
        eligibleMemberIds: const [],
        othersAttending: const [],
        kingsMessengers: const [messenger],
      );

      expect(event.kingsMessengers, [messenger]);
    });

    test('maps every known db event type', () {
      const cases = {
        'frat_night': EventType.fratNight,
        'excursion': EventType.excursion,
        'ranch': EventType.ranch,
        'commitment_ceremony': EventType.commitmentCeremony,
        'ceremony': EventType.ceremony,
      };

      for (final entry in cases.entries) {
        final event = Event.fromJson(
          _baseJson(type: entry.key),
          memberLabels: const {},
          eligibleMemberIds: const [],
          othersAttending: const [],
          kingsMessengers: const [],
        );
        expect(event.type, entry.value, reason: 'db type "${entry.key}"');
      }
    });

    test(
      'an unrecognized db event type falls back to custom rather than throwing',
      () {
        final event = Event.fromJson(
          _baseJson(type: 'some_future_type'),
          memberLabels: const {},
          eligibleMemberIds: const [],
          othersAttending: const [],
          kingsMessengers: const [],
        );

        expect(event.type, EventType.custom);
      },
    );
  });

  group('Event.registeredCount', () {
    test('is zero with no household RSVPs and no othersAttending', () {
      final event = Event.fromJson(
        _baseJson(),
        memberLabels: const {},
        eligibleMemberIds: const [],
        othersAttending: const [],
        kingsMessengers: const [],
      );

      expect(event.registeredCount, 0);
    });

    test('counts only accepted household RSVPs, not declined/tentative', () {
      final event = Event.fromJson(
        _baseJson(
          rsvps: [
            _rsvpJson(memberId: 'member-1', response: 'accepted'),
            _rsvpJson(memberId: 'member-2', response: 'declined'),
            _rsvpJson(memberId: 'member-3', response: 'tentative'),
          ],
        ),
        memberLabels: const {},
        eligibleMemberIds: const [],
        othersAttending: const [],
        kingsMessengers: const [],
      );

      expect(event.registeredCount, 1);
    });

    test('adds othersAttending on top of accepted household RSVPs', () {
      final event = Event.fromJson(
        _baseJson(
          rsvps: [_rsvpJson(memberId: 'member-1', response: 'accepted')],
        ),
        memberLabels: const {},
        eligibleMemberIds: const [],
        othersAttending: const [
          EventAttendee(id: 'member-2', name: 'Jane Doe'),
          EventAttendee(id: 'member-3', name: 'Jack Doe'),
        ],
        kingsMessengers: const [],
      );

      expect(event.registeredCount, 3);
    });
  });

  group('EventTypeIcon.iconName', () {
    test('has an icon for every event type, including the custom fallback', () {
      for (final type in EventType.values) {
        expect(type.iconName, isNotEmpty);
      }
    });
  });
}
