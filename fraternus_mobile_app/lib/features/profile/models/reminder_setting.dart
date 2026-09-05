/// The 7 reminder types from app_concept.md's `User Reminder` Data Model.
/// Event cancellation is deliberately not a value here — per
/// app_concept.md's note, it corrects stale information a user already
/// opted into (they RSVP'd) rather than being a discretionary reminder, so
/// it isn't user-toggleable the way these seven are.
enum ReminderType {
  fieldGuideMorning,
  fieldGuideEvening,
  newChallenge,
  challengeMidWeek,
  challengeLastDay,
  event24hr,
  event1hr;

  /// Matches the Postgres `reminder_type` enum's snake_case values exactly.
  String toJson() => switch (this) {
    ReminderType.fieldGuideMorning => 'field_guide_morning',
    ReminderType.fieldGuideEvening => 'field_guide_evening',
    ReminderType.newChallenge => 'new_challenge',
    ReminderType.challengeMidWeek => 'challenge_mid_week',
    ReminderType.challengeLastDay => 'challenge_last_day',
    ReminderType.event24hr => 'event_24hr',
    ReminderType.event1hr => 'event_1hr',
  };

  static ReminderType fromJson(String value) => switch (value) {
    'field_guide_morning' => ReminderType.fieldGuideMorning,
    'field_guide_evening' => ReminderType.fieldGuideEvening,
    'new_challenge' => ReminderType.newChallenge,
    'challenge_mid_week' => ReminderType.challengeMidWeek,
    'challenge_last_day' => ReminderType.challengeLastDay,
    'event_24hr' => ReminderType.event24hr,
    'event_1hr' => ReminderType.event1hr,
    _ => throw ArgumentError('Unknown reminder type: $value'),
  };

  /// Display copy is UI-only, never stored server-side — the schema only
  /// ever needs [type] and [ReminderSetting.enabled].
  String get label => switch (this) {
    ReminderType.fieldGuideMorning => 'Daily Reading',
    ReminderType.fieldGuideEvening => 'Evening Seal',
    ReminderType.newChallenge => 'Introduction',
    ReminderType.challengeMidWeek => 'Midweek Check-In',
    ReminderType.challengeLastDay => 'Last Chance',
    ReminderType.event24hr => '24 Hours Before',
    ReminderType.event1hr => '1 Hour Before',
  };

  String get timeLabel => switch (this) {
    ReminderType.fieldGuideMorning => '7:00 AM',
    ReminderType.fieldGuideEvening => '9:00 PM',
    ReminderType.newChallenge => 'Wednesdays at 7AM',
    ReminderType.challengeMidWeek => 'Fridays at 7AM',
    ReminderType.challengeLastDay => 'Mondays at 6PM',
    ReminderType.event24hr => '24 hours before the event',
    ReminderType.event1hr => '1 hour before the event',
  };
}

class ReminderSetting {
  const ReminderSetting({required this.type, required this.enabled});

  final ReminderType type;
  final bool enabled;

  String get id => type.name;
  String get label => type.label;
  String get timeLabel => type.timeLabel;

  ReminderSetting copyWith({bool? enabled}) {
    return ReminderSetting(type: type, enabled: enabled ?? this.enabled);
  }
}

/// Three display groups over the 7 [ReminderType]s — grouping is UI-only,
/// there's no "group" concept in the schema.
class ReminderGroup {
  const ReminderGroup({required this.title, required this.reminders});

  final String title;
  final List<ReminderSetting> reminders;

  static const groupedTypes = {
    'Field Guide': [
      ReminderType.fieldGuideMorning,
      ReminderType.fieldGuideEvening,
    ],
    'Weekly Challenges': [
      ReminderType.newChallenge,
      ReminderType.challengeMidWeek,
      ReminderType.challengeLastDay,
    ],
    'Events': [ReminderType.event24hr, ReminderType.event1hr],
  };
}
