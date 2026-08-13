/// Not a schema entity — a read-model listing the current user's household
/// members for the Challenge tab. Unlike Events (which have real per-event
/// eligibility tables — `Event Attendees Chapter`/`Event Attendees
/// Specific`), the schema has no per-challenge eligibility concept at all:
/// every Member is eligible for every Challenge. So this is a
/// household-level list, not something attached to an individual
/// `WeeklyChallenge` — the same set applies across all challenges. A
/// `Challenge Member` row (see [PersonChallengeProgress]) only exists once
/// a household member has committed to a given challenge, so this is the
/// only place an as-yet-unaccepted household member's name comes from.
class ChallengeHouseholdMember {
  const ChallengeHouseholdMember({required this.memberId, required this.label});

  final String memberId;
  final String label;
}
