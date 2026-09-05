import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/design_system/design_system.dart' show RsvpStatus;
import 'package:fraternus_mobile_app/features/events/data/events_repository.dart';

void main() {
  group('StaticEventsRepository.fetchEvents', () {
    test('returns all 5 seeded events regardless of memberLabels', () async {
      final repository = StaticEventsRepository();

      final events = await repository.fetchEvents(asOf: DateTime.now(), memberLabels: const {});

      expect(events.map((e) => e.id).toSet(), {
        'captain-meeting',
        'hawc-night',
        'frat-night',
        'excursion-buffalo-river',
        'ranch',
      });
    });

    test('the captain meeting is limited to the captains-only household', () async {
      final repository = StaticEventsRepository();

      final events = await repository.fetchEvents(asOf: DateTime.now(), memberLabels: const {});

      final meeting = events.firstWhere((e) => e.id == 'captain-meeting');
      expect(meeting.eligibleHouseholdMembers.map((m) => m.memberId), ['you']);
    });

    test('a submitted RSVP is reflected in the next fetch\'s householdRsvps', () async {
      final repository = StaticEventsRepository();

      await repository.submitRsvp(
        eventId: 'excursion-buffalo-river',
        memberId: 'you',
        status: RsvpStatus.yes,
      );

      final events = await repository.fetchEvents(asOf: DateTime.now(), memberLabels: const {});
      final excursion = events.firstWhere((e) => e.id == 'excursion-buffalo-river');
      // jack and thomas are pre-seeded; "you" is the newly-added RSVP.
      expect(excursion.householdRsvps, hasLength(3));
      expect(
        excursion.householdRsvps.firstWhere((r) => r.memberId == 'you').status,
        RsvpStatus.yes,
      );
    });

    test(
      'every seeded event rebuilds householdRsvps from _rsvps, not a stale literal '
      '(regression test: hawc-night/frat-night/ranch used to hardcode householdRsvps '
      'to const [], so a submitted RSVP never surfaced on refetch for those three)',
      () async {
        final repository = StaticEventsRepository();

        for (final eventId in ['hawc-night', 'frat-night', 'ranch']) {
          await repository.submitRsvp(eventId: eventId, memberId: 'you', status: RsvpStatus.yes);
        }

        final events = await repository.fetchEvents(asOf: DateTime.now(), memberLabels: const {});
        for (final eventId in ['hawc-night', 'frat-night', 'ranch']) {
          final event = events.firstWhere((e) => e.id == eventId);
          expect(
            event.householdRsvps.where((r) => r.memberId == 'you' && r.status == RsvpStatus.yes),
            hasLength(1),
            reason: '$eventId should reflect the RSVP just submitted for it',
          );
        }
      },
    );
  });

  group('StaticEventsRepository.submitRsvp', () {
    test('a fresh RSVP returns the new row', () async {
      final repository = StaticEventsRepository();

      final rsvp = await repository.submitRsvp(
        eventId: 'hawc-night',
        memberId: 'you',
        status: RsvpStatus.tentative,
      );

      expect(rsvp, isNotNull);
      expect(rsvp!.status, RsvpStatus.tentative);
    });

    test('re-submitting the same status clears the RSVP and returns null', () async {
      final repository = StaticEventsRepository();
      await repository.submitRsvp(eventId: 'hawc-night', memberId: 'you', status: RsvpStatus.yes);

      final result = await repository.submitRsvp(
        eventId: 'hawc-night',
        memberId: 'you',
        status: RsvpStatus.yes,
      );

      expect(result, isNull);
      final events = await repository.fetchEvents(asOf: DateTime.now(), memberLabels: const {});
      final hawc = events.firstWhere((e) => e.id == 'hawc-night');
      expect(hawc.householdRsvps.any((r) => r.memberId == 'you'), isFalse);
    });

    test('submitting a different status overwrites the previous one, not toggling it off', () async {
      final repository = StaticEventsRepository();
      await repository.submitRsvp(eventId: 'hawc-night', memberId: 'you', status: RsvpStatus.no);

      final result = await repository.submitRsvp(
        eventId: 'hawc-night',
        memberId: 'you',
        status: RsvpStatus.yes,
      );

      expect(result, isNotNull);
      expect(result!.status, RsvpStatus.yes);
    });

    test('the pre-seeded captain-meeting RSVP for "you" already exists', () async {
      final repository = StaticEventsRepository();

      // Re-submitting the seeded status should clear it (proves the seed
      // data and submitRsvp share the same '$eventId:$memberId' key format).
      final result = await repository.submitRsvp(
        eventId: 'captain-meeting',
        memberId: 'you',
        status: RsvpStatus.yes,
      );

      expect(result, isNull);
    });
  });
}
