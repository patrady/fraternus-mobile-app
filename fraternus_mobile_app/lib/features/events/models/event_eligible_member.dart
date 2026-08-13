/// Not a schema entity — a read-model listing which household members are
/// eligible to RSVP to an event (derived from `Event Attendees Chapter`/
/// `Event Attendees Specific` joined against household composition),
/// independent of whether they've actually responded yet. An `Event RSVP`
/// row (see [HouseholdRsvp]) only exists once a response has been
/// submitted, so this is the only place an unanswered household member's
/// name comes from.
class EventEligibleMember {
  const EventEligibleMember({required this.memberId, required this.label});

  final String memberId;
  final String label;
}
