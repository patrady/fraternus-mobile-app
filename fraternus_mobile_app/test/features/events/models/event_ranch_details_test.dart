import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/events/models/event_ranch_details.dart';

void main() {
  group('EventRanchDetails.fromJson', () {
    test('parses a present registration_url', () {
      final details = EventRanchDetails.fromJson({
        'id': 'details-1',
        'event_id': 'event-1',
        'registration_url': 'https://example.com/register',
      });

      expect(details.registrationUrl, 'https://example.com/register');
    });

    test('a null registration_url defaults to empty string', () {
      final details = EventRanchDetails.fromJson({
        'id': 'details-1',
        'event_id': 'event-1',
        'registration_url': null,
      });

      expect(details.registrationUrl, '');
    });
  });
}
