/// The logged-in account — adapted from docs/app_concept.md's `User` table.
/// Named `AppUser` rather than `User` to avoid colliding with a future
/// Auth0/Firebase `User` type once real auth is wired up.
class AppUser {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
    required this.lastModifiedAt,
  });

  final String id;
  final String firstName;
  final String lastName;

  /// Sourced from the linked Self-relationship [Member]'s own `email` at
  /// signup time — `Member.email` is the field actually collected, this is
  /// populated from it rather than independently.
  final String email;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  String get fullName => '$firstName $lastName';

  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  AppUser copyWith({String? firstName, String? lastName, String? email}) {
    return AppUser(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      createdAt: createdAt,
      lastModifiedAt: lastModifiedAt,
    );
  }
}
