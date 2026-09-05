import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/events/models/event_attendees_chapter.dart';

void main() {
  group('EventAttendeesChapter.fromJson', () {
    test('parses each known role', () {
      for (final role in EventAttendeeChapterRole.values) {
        final row = EventAttendeesChapter.fromJson({
          'id': 'row-1',
          'event_id': 'event-1',
          'chapter_key': 'chapter-1',
          'role': role.name,
        });
        expect(row.role, role);
      }
    });

    test('an unrecognized role throws rather than silently defaulting', () {
      expect(
        () => EventAttendeesChapter.fromJson({
          'id': 'row-1',
          'event_id': 'event-1',
          'chapter_key': 'chapter-1',
          'role': 'not_a_role',
        }),
        throwsArgumentError,
      );
    });
  });
}
