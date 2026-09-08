import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/events/models/event_attendee.dart';

void main() {
  group('EventAttendee.fromJson', () {
    test('joins first and last name', () {
      final attendee = EventAttendee.fromJson({
        'member_id': 'member-1',
        'first_name': 'John',
        'last_name': 'Smith',
      });

      expect(attendee.id, 'member-1');
      expect(attendee.name, 'John Smith');
    });

    test('is_hawc and officer_roles default to false/empty when absent', () {
      final attendee = EventAttendee.fromJson({
        'member_id': 'member-1',
        'first_name': 'John',
        'last_name': 'Smith',
      });

      expect(attendee.isHawc, isFalse);
      expect(attendee.officerRoles, isEmpty);
      expect(attendee.topOfficerRole, isNull);
    });

    test('parses is_hawc and sorts officer_roles by priority ascending', () {
      final attendee = EventAttendee.fromJson({
        'member_id': 'member-1',
        'first_name': 'John',
        'last_name': 'Smith',
        'is_hawc': true,
        'officer_roles': [
          {
            'key': 'excursion_officer',
            'label': 'Excursion Officer',
            'priority': 4,
          },
          {'key': 'commander', 'label': 'Commander', 'priority': 1},
        ],
      });

      expect(attendee.isHawc, isTrue);
      expect(attendee.officerRoles.map((r) => r.key), [
        'commander',
        'excursion_officer',
      ]);
      expect(attendee.topOfficerRole?.key, 'commander');
    });
  });

  group('EventAttendee.initials', () {
    test('takes first letter of first and last name', () {
      expect(const EventAttendee(id: '1', name: 'John Smith').initials, 'JS');
    });

    test('a single-word name uses just that letter', () {
      expect(const EventAttendee(id: '1', name: 'Cher').initials, 'C');
    });

    test('collapses repeated whitespace between name parts', () {
      expect(const EventAttendee(id: '1', name: 'John   Smith').initials, 'JS');
    });

    test('an empty name has no initials', () {
      expect(const EventAttendee(id: '1', name: '').initials, '');
    });
  });
}
