/// One household member's answers/completion for a single day's
/// devotional — schema's "Field Guide Daily Devotional Member". [personKey]
/// stands in for the schema's Member Id, using this app's existing
/// you/jack/thomas convention (see [PersonChallengeProgress.personKey]).
class FieldGuideDailyDevotionalMember {
  const FieldGuideDailyDevotionalMember({
    required this.id,
    required this.dailyDevotionalId,
    required this.personKey,
    this.sword,
    this.spade,
    this.completedDate,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String dailyDevotionalId;
  final String personKey;

  /// Copied text of whichever Sword Option this member picked — not an
  /// index, per the schema.
  final String? sword;

  /// This member's free-text answer to the day's Spade prompt.
  final String? spade;
  final DateTime? completedDate;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  bool get isCompleted => completedDate != null;

  FieldGuideDailyDevotionalMember copyWith({
    String? sword,
    String? spade,
    DateTime? completedDate,
    bool clearCompleted = false,
  }) {
    return FieldGuideDailyDevotionalMember(
      id: id,
      dailyDevotionalId: dailyDevotionalId,
      personKey: personKey,
      sword: sword ?? this.sword,
      spade: spade ?? this.spade,
      completedDate: clearCompleted ? null : (completedDate ?? this.completedDate),
      createdAt: createdAt,
      lastModifiedAt: lastModifiedAt,
    );
  }
}
