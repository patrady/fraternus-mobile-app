/// The logged-in account — adapted from docs/app_concept.md's `User` table.
/// Named `AppUser` rather than `User` to avoid colliding with a future
/// Auth0/Firebase `User` type once real auth is wired up.
class AppUser {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;

  String get fullName => '$firstName $lastName';

  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  AppUser copyWith({String? firstName, String? lastName, String? email}) {
    return AppUser(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
    );
  }
}
