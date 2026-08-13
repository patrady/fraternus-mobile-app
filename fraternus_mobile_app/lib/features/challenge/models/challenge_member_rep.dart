/// Adapted from docs/app_concept.md's `Challenge Member Rep` table — one
/// completed rep. This row only exists once a rep is actually completed, so
/// [createdAt] doubles as the completed-date; there's no separate
/// "completed" flag or date field.
class ChallengeMemberRep {
  const ChallengeMemberRep({
    required this.id,
    required this.challengeMemberId,
    required this.completedByUserId,
    required this.number,
    required this.createdAt,
  });

  final String id;
  final String challengeMemberId;

  /// The User (Guardian/Captain, or the Member themselves) who marked this
  /// rep complete — lets a parent complete a rep on behalf of a child.
  final String completedByUserId;

  /// Which rep this is, e.g. 2 of 3.
  final int number;
  final DateTime createdAt;
}
