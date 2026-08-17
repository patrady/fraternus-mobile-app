/// Adapted from docs/app_concept.md's `User Member Association` table —
/// links a [AppUser] to a [Member] they can act on behalf of.
enum AssociationRelationship { self, guardian }

/// COPPA guardian-consent state, tracked on Guardian association rows for
/// Members under 13. Null/unused for Self associations and for Guardian
/// associations of Members 13 or older.
enum ConsentStatus { pending, granted, revoked }

class UserMemberAssociation {
  const UserMemberAssociation({
    required this.id,
    required this.userId,
    required this.memberId,
    required this.relationship,
    this.consentStatus,
    this.consentDate,
    this.consentMethod,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String userId;
  final String memberId;
  final AssociationRelationship relationship;

  /// Applicable when [relationship] is Guardian and the Member is under 13.
  final ConsentStatus? consentStatus;
  final DateTime? consentDate;

  /// e.g. "email confirmation".
  final String? consentMethod;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  factory UserMemberAssociation.fromJson(Map<String, dynamic> json) {
    return UserMemberAssociation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      memberId: json['member_id'] as String,
      relationship: AssociationRelationship.values.byName(json['relationship'] as String),
      consentStatus: json['consent_status'] == null
          ? null
          : ConsentStatus.values.byName(json['consent_status'] as String),
      consentDate: json['consent_date'] == null ? null : DateTime.parse(json['consent_date'] as String),
      consentMethod: json['consent_method'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
