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
  /// this RSVP.
  final String submittedByUserId;
  final RsvpStatus status;
  final DateTime createdAt;
  final DateTime lastModifiedAt;
}
