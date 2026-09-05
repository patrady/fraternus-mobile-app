import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/design_system/design_system.dart' show RsvpStatus;
import 'package:fraternus_mobile_app/features/events/models/household_rsvp.dart';

void main() {
  group('HouseholdRsvp.fromJson status mapping', () {
    test('maps each known db response value to its RsvpStatus', () {
      final cases = {'accepted': RsvpStatus.yes, 'declined': RsvpStatus.no, 'tentative': RsvpStatus.tentative};

      for (final entry in cases.entries) {
        final rsvp = HouseholdRsvp.fromJson({
          'id': 'rsvp-1',
          'event_id': 'event-1',
          'member_id': 'member-1',
          'submitted_by_user_id': 'user-1',
          'response': entry.key,
          'created_at': '2026-01-01T00:00:00Z',
          'updated_at': '2026-01-01T00:00:00Z',
        });
        expect(rsvp.status, entry.value, reason: 'response "${entry.key}"');
      }
    });

    test('an unrecognized db value throws rather than silently defaulting', () {
      expect(
        () => HouseholdRsvp.fromJson({
          'id': 'rsvp-1',
          'event_id': 'event-1',
          'member_id': 'member-1',
          'submitted_by_user_id': 'user-1',
          'response': 'maybe',
          'created_at': '2026-01-01T00:00:00Z',
          'updated_at': '2026-01-01T00:00:00Z',
        }),
        throwsArgumentError,
      );
    });

    test('submittedByUserId parses to null when the submitter has been deleted', () {
      final rsvp = HouseholdRsvp.fromJson({
        'id': 'rsvp-1',
        'event_id': 'event-1',
        'member_id': 'member-1',
        'submitted_by_user_id': null,
        'response': 'accepted',
        'created_at': '2026-01-01T00:00:00Z',
        'updated_at': '2026-01-01T00:00:00Z',
      });

      expect(rsvp.submittedByUserId, isNull);
    });
  });

  group('HouseholdRsvp.statusToDb', () {
    test('is the exact inverse of the fromJson mapping', () {
      const dbValues = {RsvpStatus.yes: 'accepted', RsvpStatus.no: 'declined', RsvpStatus.tentative: 'tentative'};

      for (final entry in dbValues.entries) {
        expect(HouseholdRsvp.statusToDb(entry.key), entry.value);
      }
    });
  });
}
