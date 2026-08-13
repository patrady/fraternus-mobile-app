/// Adapted from docs/app_concept.md's `User Member Association` table —
/// links a [AppUser] to a [Member] they can act on behalf of.
enum AssociationRelationship { self, guardian }

class UserMemberAssociation {
  const UserMemberAssociation({
    required this.userId,
    required this.memberId,
    required this.relationship,
  });

  final String userId;
  final String memberId;
  final AssociationRelationship relationship;
}
