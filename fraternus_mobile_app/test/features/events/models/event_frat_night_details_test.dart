import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/events/models/event_frat_night_details.dart';

void main() {
  test('EventFratNightDetails.fromJson maps every field', () {
    final details = EventFratNightDetails.fromJson({
      'id': 'details-1',
      'event_id': 'event-1',
      'frat_night_template_key': 'week-1',
      'chapter_key': 'chapter-1',
    });

    expect(details.id, 'details-1');
    expect(details.eventId, 'event-1');
    expect(details.fratNightTemplateKey, 'week-1');
    expect(details.chapterKey, 'chapter-1');
  });
}
