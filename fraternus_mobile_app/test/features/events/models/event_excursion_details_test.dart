import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/events/models/event_excursion_details.dart';

void main() {
  group('EventExcursionDetails.fromJson', () {
    test('parses a present registration_url', () {
      final details = EventExcursionDetails.fromJson({
        'id': 'details-1',
        'event_id': 'event-1',
        'host_chapter_key': 'chapter-1',
        'registration_url': 'https://example.com/register',
      });

      expect(details.registrationUrl, 'https://example.com/register');
    });

    test('a null registration_url defaults to empty string', () {
      final details = EventExcursionDetails.fromJson({
        'id': 'details-1',
        'event_id': 'event-1',
        'host_chapter_key': 'chapter-1',
        'registration_url': null,
      });

      expect(details.registrationUrl, '');
    });
  });
}
