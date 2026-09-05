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
