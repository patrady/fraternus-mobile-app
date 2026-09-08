/// Adapted from docs/app_concept.md's `Member` table.
enum MemberRole { brother, captain }

/// Adapted from docs/app_concept.md's `Officer Role` reference table — a
/// small, hand-seeded set of leadership titles (Commander, HAWC Officer,
/// Frat Night Officer, Excursion Officer) a Member can hold any combination
/// of. [priority] lets the UI pick a single one to show as a badge when it
/// only has room for one; it's not itself a UI concept.
class OfficerRole {
  const OfficerRole({
    required this.key,
    required this.label,
    required this.priority,
  });

  final String key;
  final String label;
  final int priority;

  factory OfficerRole.fromJson(Map<String, dynamic> json) {
    return OfficerRole(
      key: json['key'] as String,
      label: json['label'] as String,
      priority: json['priority'] as int,
    );
  }
}

/// Anyone registered with Fraternus — a Brother or a Captain. The
/// logged-in [AppUser] and their children are all `Member`s; a
/// [UserMemberAssociation] links a User to each Member they can act on
/// behalf of (Self or Guardian).
class Member {
  const Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.chapterKey,
    this.email,
    this.isHawc = false,
    this.officerRoles = const [],
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final MemberRole role;

  /// A Member always belongs to exactly one chapter.
  final String chapterKey;

  /// Not present in app_concept.md's literal Member table, but its
  /// signup-flow prose explicitly says a Brother's creation captures an
  /// optional email ("email is optional since Brothers may not have one").
  /// This is the field actually collected at signup — [AppUser.email] is
  /// sourced from here for a Self-relationship Member, not the reverse.
  final String? email;

  /// Participation flag, independent of [officerRoles] — applies to
  /// Brothers and Captains alike, whereas officer roles are leadership
  /// titles.
  final bool isHawc;

  /// Every Officer Role this Member currently holds, sorted by
  /// [OfficerRole.priority] ascending.
  final List<OfficerRole> officerRoles;

  /// The single highest-priority [OfficerRole] this Member holds, if any —
  /// [officerRoles] is pre-sorted, so this is just its first entry.
  OfficerRole? get topOfficerRole =>
      officerRoles.isEmpty ? null : officerRoles.first;

  final DateTime createdAt;
  final DateTime lastModifiedAt;

  String get fullName => '$firstName $lastName';

  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  Member copyWith({
    String? firstName,
    String? lastName,
    String? email,
    bool clearEmail = false,
    String? chapterKey,
  }) {
    return Member(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role,
      chapterKey: chapterKey ?? this.chapterKey,
      email: clearEmail ? null : (email ?? this.email),
      isHawc: isHawc,
      officerRoles: officerRoles,
      createdAt: createdAt,
      lastModifiedAt: lastModifiedAt,
    );
  }

  factory Member.fromJson(Map<String, dynamic> json) {
    final officerRoles = [
      for (final row
          in (json['member_officer_roles'] as List<dynamic>? ?? const []))
        OfficerRole.fromJson(
          (row as Map<String, dynamic>)['officer_roles']
              as Map<String, dynamic>,
        ),
    ]..sort((a, b) => a.priority.compareTo(b.priority));

    return Member(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      role: MemberRole.values.byName(json['role'] as String),
      chapterKey: json['chapter_key'] as String,
      email: json['email'] as String?,
      isHawc: json['is_hawc'] as bool? ?? false,
      officerRoles: officerRoles,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
