/// Adapted from docs/app_concept.md's `Member` table.
enum MemberRole { brother, captain, commander }

/// Anyone registered with Fraternus — a Brother, Captain, or Commander.
/// The logged-in [AppUser] and their children are all `Member`s; a
/// [UserMemberAssociation] links a User to each Member they can act on
/// behalf of (Self or Guardian).
class Member {
  const Member({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.chapterId,
    required this.birthday,
    this.email,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final MemberRole role;

  /// A Member always belongs to exactly one chapter.
  final String chapterId;

  /// Required for every Member regardless of role — Brother, Captain, or
  /// Commander all collect a birthday at creation time.
  final DateTime birthday;

  /// Not present in app_concept.md's literal Member table, but its
  /// signup-flow prose explicitly says a Brother's creation captures an
  /// optional email ("email is optional since Brothers may not have one").
  /// This is the field actually collected at signup — [AppUser.email] is
  /// sourced from here for a Self-relationship Member, not the reverse.
  final String? email;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  String get fullName => '$firstName $lastName';

  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  Member copyWith({
    String? firstName,
    String? lastName,
    DateTime? birthday,
    String? email,
    bool clearEmail = false,
    String? chapterId,
  }) {
    return Member(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      role: role,
      chapterId: chapterId ?? this.chapterId,
      birthday: birthday ?? this.birthday,
      email: clearEmail ? null : (email ?? this.email),
      createdAt: createdAt,
      lastModifiedAt: lastModifiedAt,
    );
  }
}
