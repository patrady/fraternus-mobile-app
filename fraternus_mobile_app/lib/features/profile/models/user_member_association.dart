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
}
