/// A local Fraternus chapter — adapted from docs/app_concept.md's `Chapter`
/// table. Shared (not feature-local) since Field Guide's "Chapter Field
/// Guide Details" and Events' attendee/frat-night logic will reference it
/// too, even though those features don't consume it yet.
class Chapter {
  const Chapter({
    required this.id,
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
  final String name;
  final String city;
  final String state;
  final String zipCode;

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
}

/// Hardcoded stand-in for a future Chapters API — same seam pattern as
/// every other Static*Repository in this app (see e.g.
/// StaticChallengeRepository's own doc comment).
const seedChapters = [
  Chapter(
    id: 'st-philips-franklin',
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
