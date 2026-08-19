/// Not a schema entity — a read-model listing the current user's household
/// members for the Guide tab's person tabs. Every household Member sees
/// the same daily devotional (no per-member eligibility concept the way
/// Events has), but `field_guide_daily_devotional_members` rows are only
/// created lazily — via `upsertDevotionalMember` — the first time a member
/// interacts with a given day, so a member who hasn't touched today's
/// reading yet has no row at all. Iterating this household list (rather
/// than the fetched devotional's own `members`) is what keeps every
/// household member's tab visible regardless of whether they've started
/// today's reading — same shape as Challenge's `ChallengeHouseholdMember`.
class GuideHouseholdMember {
  const GuideHouseholdMember({required this.memberId, required this.label});

  final String memberId;
  final String label;
}
