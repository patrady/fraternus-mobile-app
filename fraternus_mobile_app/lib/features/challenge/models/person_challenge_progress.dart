class PersonChallengeProgress {
  const PersonChallengeProgress({
    required this.personKey,
    required this.label,
    required this.accepted,
    required this.repCompletions,
    this.streakCount = 0,
  });

  final String personKey;
  final String label;
  final bool accepted;

  /// One entry per rep — the completion date, or null if that rep isn't
  /// done yet.
  final List<DateTime?> repCompletions;

  /// Only meaningful/shown once [isCompleted] is true.
  final int streakCount;

  int get repsDone => repCompletions.where((date) => date != null).length;

  bool get isCompleted => accepted && repsDone == repCompletions.length;

  PersonChallengeProgress copyWith({bool? accepted, List<DateTime?>? repCompletions}) {
    return PersonChallengeProgress(
      personKey: personKey,
      label: label,
      accepted: accepted ?? this.accepted,
      repCompletions: repCompletions ?? this.repCompletions,
      streakCount: streakCount,
    );
  }
}
