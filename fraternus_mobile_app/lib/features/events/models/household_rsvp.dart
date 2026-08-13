import '../../../design_system/design_system.dart' show RsvpStatus;

/// One household member's RSVP row for a single event — schema's "Event
/// RSVP". Which household members appear here is scope-dependent (e.g. a
/// captains-only event only lists captain household members) — seeded per
/// event, not derived.
class HouseholdRsvp {
  const HouseholdRsvp({
    required this.id,
    required this.eventId,
    required this.memberId,
    required this.label,
    this.submittedByUserId,
    this.status,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String eventId;
  final String memberId;

  /// Display name — a denormalized read-model convenience, not a schema
  /// field; joined from [Member] rather than stored/synced as-is.
  final String label;

  /// The User (Guardian/Captain, or the Member themselves) who submitted
  /// this RSVP.
  final String? submittedByUserId;
  final RsvpStatus? status;
  final DateTime createdAt;
  final DateTime lastModifiedAt;
}
