import '../../../design_system/design_system.dart' show RsvpStatus;

/// One household member's RSVP row for a single event. Which household
/// members appear here is scope-dependent (e.g. a captains-only event only
/// lists captain household members) — seeded per event, not derived.
class HouseholdRsvp {
  const HouseholdRsvp({required this.personKey, required this.label, this.status});

  final String personKey;
  final String label;
  final RsvpStatus? status;
}
