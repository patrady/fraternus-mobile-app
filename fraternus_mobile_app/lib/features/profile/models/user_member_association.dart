/// Adapted from docs/app_concept.md's `User Member Association` table —
/// links a [AppUser] to a [Member] they can act on behalf of.
enum AssociationRelationship { self, guardian }

class UserMemberAssociation {
  const UserMemberAssociation({
    required this.id,
    required this.userId,
    required this.memberId,
    required this.relationship,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String userId;
  final String memberId;
  final AssociationRelationship relationship;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  factory UserMemberAssociation.fromJson(Map<String, dynamic> json) {
    return UserMemberAssociation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      memberId: json['member_id'] as String,
      relationship: AssociationRelationship.values.byName(json['relationship'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
