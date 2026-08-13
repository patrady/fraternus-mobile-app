/// Notification reminder preferences. Not a schema entity in
/// docs/app_concept.md — reminders are described there purely as
/// notification behavior, so this is a Profile-local, UI-only concept.
class ReminderSetting {
  const ReminderSetting({
    required this.id,
    required this.label,
    required this.timeLabel,
    required this.enabled,
  });

  final String id;
  final String label;

  /// e.g. '7:00 AM', 'Wednesdays at 7AM', '30 minutes before'.
  final String timeLabel;
  final bool enabled;

  ReminderSetting copyWith({bool? enabled}) {
    return ReminderSetting(
      id: id,
      label: label,
      timeLabel: timeLabel,
      enabled: enabled ?? this.enabled,
    );
  }
}

class ReminderGroup {
  const ReminderGroup({required this.title, required this.reminders});

  final String title;
  final List<ReminderSetting> reminders;
}
