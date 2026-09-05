import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/events/models/event_location.dart';

void main() {
  group('EventLocation.fromJson', () {
    test('parses all fields, including the nullable ones', () {
      final location = EventLocation.fromJson({
        'id': 'location-1',
        'name': 'Parish Hall',
        'description': 'Main hall',
        'street': '123 Main St',
        'city': 'Franklin',
        'state': 'TN',
        'zip_code': '37064',
        'notes': 'Enter through the side door',
      });

      expect(location.name, 'Parish Hall');
      expect(location.street, '123 Main St');
    });

    test('nullable fields default to null when absent', () {
      final location = EventLocation.fromJson({'id': 'location-1', 'name': 'Parish Hall'});

      expect(location.description, isNull);
      expect(location.street, isNull);
      expect(location.city, isNull);
      expect(location.state, isNull);
      expect(location.zipCode, isNull);
    });
  });

  group('EventLocation.address', () {
    test('joins street, city, and state+zip when all present', () {
      const location = EventLocation(
        id: '1',
        name: 'Parish Hall',
        street: '123 Main St',
        city: 'Franklin',
        state: 'TN',
        zipCode: '37064',
      );

      expect(location.address, '123 Main St, Franklin, TN 37064');
    });

    test('omits street when absent', () {
      const location = EventLocation(id: '1', name: 'Parish Hall', city: 'Franklin', state: 'TN', zipCode: '37064');

      expect(location.address, 'Franklin, TN 37064');
    });

    test('a city with no state or zip has no trailing separator', () {
      const location = EventLocation(id: '1', name: 'Parish Hall', city: 'Franklin');

      expect(location.address, 'Franklin');
    });

    test('is empty when no address fields are set', () {
      const location = EventLocation(id: '1', name: 'Parish Hall');

      expect(location.address, '');
    });
  });

  group('EventLocation.mapQuery', () {
    test('combines name and address', () {
      const location = EventLocation(id: '1', name: 'Parish Hall', city: 'Franklin', state: 'TN');

      expect(location.mapQuery, 'Parish Hall, Franklin, TN');
    });

    test('falls back to just the name when there is no address', () {
      const location = EventLocation(id: '1', name: 'Parish Hall');

      expect(location.mapQuery, 'Parish Hall');
    });
  });
}
