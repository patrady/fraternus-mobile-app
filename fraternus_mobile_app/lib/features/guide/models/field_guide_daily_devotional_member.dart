/// One household member's answers/completion for a single day's
/// devotional — schema's "Field Guide Daily Devotional Member".
class FieldGuideDailyDevotionalMember {
  const FieldGuideDailyDevotionalMember({
    required this.id,
    required this.dailyDevotionalId,
    required this.memberId,
    this.submittedByUserId,
    this.sword,
    this.spade,
    this.completedDate,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String dailyDevotionalId;
  final String memberId;

  /// Whoever actually submitted the Sword/Spade — the Member themselves, or
  /// their Guardian/Captain acting on their behalf.
  final String? submittedByUserId;

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
    String? submittedByUserId,
    String? sword,
    String? spade,
    DateTime? completedDate,
    bool clearCompleted = false,
  }) {
    return FieldGuideDailyDevotionalMember(
      id: id,
      dailyDevotionalId: dailyDevotionalId,
      memberId: memberId,
      submittedByUserId: submittedByUserId ?? this.submittedByUserId,
      sword: sword ?? this.sword,
      spade: spade ?? this.spade,
      completedDate: clearCompleted ? null : (completedDate ?? this.completedDate),
      createdAt: createdAt,
      lastModifiedAt: lastModifiedAt,
    );
  }

  factory FieldGuideDailyDevotionalMember.fromJson(Map<String, dynamic> json) {
    return FieldGuideDailyDevotionalMember(
      id: json['id'] as String,
      dailyDevotionalId: json['daily_devotional_id'] as String,
      memberId: json['member_id'] as String,
      submittedByUserId: json['submitted_by_user_id'] as String?,
      sword: json['sword'] as String?,
      spade: json['spade'] as String?,
      completedDate: json['completed_date'] == null ? null : DateTime.parse(json['completed_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
