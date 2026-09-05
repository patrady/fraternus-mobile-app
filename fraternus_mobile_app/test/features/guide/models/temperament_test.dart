import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/guide/models/temperament.dart';

void main() {
  test('every temperament in temperamentOrder has a display name and a profile', () {
    for (final key in temperamentOrder) {
      expect(temperamentDisplayNames.containsKey(key), isTrue, reason: 'missing display name for $key');
      expect(temperamentProfiles.containsKey(key), isTrue, reason: 'missing profile for $key');
    }
  });

  test('temperamentDisplayNames and temperamentProfiles define no keys beyond temperamentOrder', () {
    expect(temperamentDisplayNames.keys.toSet(), temperamentOrder.toSet());
    expect(temperamentProfiles.keys.toSet(), temperamentOrder.toSet());
  });
}
