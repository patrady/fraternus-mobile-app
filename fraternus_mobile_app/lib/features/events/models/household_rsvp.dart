import '../../../design_system/design_system.dart' show RsvpStatus;

/// One household member's RSVP row for a single event — schema's "Event
/// RSVP". A row only exists once a response has actually been submitted;
/// an eligible-but-unanswered household member has no row at all (see
/// [EventEligibleMember] for how the UI knows to show them anyway).
class HouseholdRsvp {
  const HouseholdRsvp({
    required this.id,
    required this.eventId,
    required this.memberId,
    required this.submittedByUserId,
    required this.status,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String eventId;
  final String memberId;

  /// The User (Guardian/Captain, or the Member themselves) who submitted
  /// this RSVP. Nullable because the schema's FK is `on delete set null` —
  /// same treatment as `FieldGuideDailyDevotionalMember.submittedByUserId`.
  final String? submittedByUserId;
  final RsvpStatus status;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  /// The db's `rsvp_response` enum values don't match `RsvpStatus`'s
  /// literal wording (carried over as-is from app_concept.md) — this is
  /// the one place that mapping happens, both directions.
  static RsvpStatus _statusFromDb(String value) => switch (value) {
    'accepted' => RsvpStatus.yes,
    'declined' => RsvpStatus.no,
    'tentative' => RsvpStatus.tentative,
    _ => throw ArgumentError('Unknown rsvp_response: $value'),
  };

  static String statusToDb(RsvpStatus status) => switch (status) {
    RsvpStatus.yes => 'accepted',
    RsvpStatus.no => 'declined',
    RsvpStatus.tentative => 'tentative',
  };

  factory HouseholdRsvp.fromJson(Map<String, dynamic> json) {
    return HouseholdRsvp(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      memberId: json['member_id'] as String,
      submittedByUserId: json['submitted_by_user_id'] as String?,
      status: _statusFromDb(json['response'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
