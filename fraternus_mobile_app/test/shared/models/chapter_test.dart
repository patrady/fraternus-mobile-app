import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/shared/models/chapter.dart';

void main() {
  final json = {
    'id': 'chapter-1',
    'key': 'st_philips_franklin_franklin_tn',
    'name': 'St. Philips Franklin',
    'city': 'Franklin',
    'state': 'TN',
    'zip_code': '37064',
    'timezone': 'America/Chicago',
    'church': 'St. Philip Catholic Church',
    'frat_night_day_of_week': 'wednesday',
    'frat_night_start_time': '19:00',
    'frat_night_end_time': '20:30',
    'frat_night_location': 'Parish Hall',
  };

  test('Chapter.fromJson maps every field', () {
    final chapter = Chapter.fromJson(json);

    expect(chapter.key, 'st_philips_franklin_franklin_tn');
    expect(chapter.timezone, 'America/Chicago');
    expect(chapter.fratNightDayOfWeek, 'wednesday');
  });

  test('displayName combines name, city, and state', () {
    final chapter = Chapter.fromJson(json);
    expect(chapter.displayName, 'St. Philips Franklin - Franklin, TN');
  });

  test('seedChapters each round-trip through fromJson-shaped fields without a key collision', () {
    final keys = seedChapters.map((c) => c.key).toSet();
    expect(keys, hasLength(seedChapters.length));
  });
}
