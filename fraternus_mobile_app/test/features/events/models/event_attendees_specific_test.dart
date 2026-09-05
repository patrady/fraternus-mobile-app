import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/events/models/event_attendees_specific.dart';

void main() {
  test('EventAttendeesSpecific.fromJson maps every field', () {
    final row = EventAttendeesSpecific.fromJson({
      'id': 'row-1',
      'event_id': 'event-1',
      'member_id': 'member-1',
    });

    expect(row.id, 'row-1');
    expect(row.eventId, 'event-1');
    expect(row.memberId, 'member-1');
  });
}
