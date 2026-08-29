/// A local Fraternus chapter — adapted from docs/app_concept.md's `Chapter`
/// table. Shared (not feature-local) since Field Guide's "Chapter Field
/// Guide Details" and Events' attendee/frat-night logic will reference it
/// too, even though those features don't consume it yet.
class Chapter {
  const Chapter({
    required this.id,
    required this.key,
    required this.name,
    required this.city,
    required this.state,
    required this.zipCode,
    required this.timezone,
    required this.church,
    required this.fratNightDayOfWeek,
    required this.fratNightStartTime,
    required this.fratNightEndTime,
    required this.fratNightLocation,
  });

  final String id;

  /// Stable natural key, distinct from [id] — what every referencing table
  /// (Member, Chapter Field Guide Details, the Event chapter/frat-night
  /// tables) actually references.
  final String key;
  final String name;
  final String city;
  final String state;
  final String zipCode;

  /// e.g. 'St. Philips Franklin - Franklin, TN'.
  String get displayName => '$name - $city, $state';

  /// IANA identifier, e.g. 'America/Chicago'.
  final String timezone;
  final String church;

  /// e.g. 'monday'.
  final String fratNightDayOfWeek;

  /// e.g. '19:00'.
  final String fratNightStartTime;

  /// e.g. '20:30'.
  final String fratNightEndTime;
  final String fratNightLocation;

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zip_code'] as String,
      timezone: json['timezone'] as String,
      church: json['church'] as String,
      fratNightDayOfWeek: json['frat_night_day_of_week'] as String,
      fratNightStartTime: json['frat_night_start_time'] as String,
      fratNightEndTime: json['frat_night_end_time'] as String,
      fratNightLocation: json['frat_night_location'] as String,
    );
  }
}

/// Backing data for [StaticChapterRepository] (widget tests / Widgetbook)
/// now that screens read chapters through [chaptersProvider] instead of
/// this list directly — see chapter_repository.dart.
const seedChapters = [
  Chapter(
    id: 'st-philips-franklin',
    key: 'st_philips_franklin_franklin_tn',
    name: 'St. Philips Franklin',
    city: 'Franklin',
    state: 'TN',
    zipCode: '37064',
    timezone: 'America/Chicago',
    church: 'St. Philip Catholic Church',
    fratNightDayOfWeek: 'wednesday',
    fratNightStartTime: '19:00',
    fratNightEndTime: '20:30',
    fratNightLocation: 'Parish Hall',
  ),
  Chapter(
    id: 'sacred-heart',
    key: 'sacred_heart_nashville_tn',
    name: 'Sacred Heart',
    city: 'Nashville',
    state: 'TN',
    zipCode: '37215',
    timezone: 'America/Chicago',
    church: 'Sacred Heart Cathedral',
    fratNightDayOfWeek: 'thursday',
    fratNightStartTime: '19:00',
    fratNightEndTime: '20:30',
    fratNightLocation: 'Cathedral Hall',
  ),
  Chapter(
    id: 'holy-trinity',
    key: 'holy_trinity_memphis_tn',
    name: 'Holy Trinity',
    city: 'Memphis',
    state: 'TN',
    zipCode: '38103',
    timezone: 'America/Chicago',
    church: 'Holy Trinity Catholic Church',
    fratNightDayOfWeek: 'tuesday',
    fratNightStartTime: '18:30',
    fratNightEndTime: '20:00',
    fratNightLocation: 'Fellowship Hall',
  ),
];
