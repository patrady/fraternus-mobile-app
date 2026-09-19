import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/events/models/event_kings_messenger.dart';

void main() {
  group('EventKingsMessenger.fromJson', () {
    test('joins first and last name', () {
      final messenger = EventKingsMessenger.fromJson({
        'member_id': 'member-1',
        'first_name': 'John',
        'last_name': 'Smith',
      });

      expect(messenger.memberId, 'member-1');
      expect(messenger.name, 'John Smith');
    });
  });

  group('EventKingsMessenger.initials', () {
    test('takes first letter of first and last name', () {
      expect(
        const EventKingsMessenger(
          memberId: '1',
          firstName: 'John',
          lastName: 'Smith',
        ).initials,
        'JS',
      );
    });

    test('a single-word name uses just that letter', () {
      expect(
        const EventKingsMessenger(
          memberId: '1',
          firstName: 'Cher',
          lastName: '',
        ).initials,
        'C',
      );
    });
  });
}
