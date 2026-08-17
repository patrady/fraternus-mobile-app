/// The logged-in account — adapted from docs/app_concept.md's `User` table.
/// Named `AppUser` rather than `User` to avoid colliding with Supabase's
/// own `User` type (`package:supabase_flutter`, the GoTrue auth user).
class AppUser {
  const AppUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isRemindersEnabled,
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

  /// Master switch — app_concept.md's `User`.`Is Reminders Enabled`. When
  /// false, no reminder is sent regardless of any individual
  /// `ReminderSetting`.
  final bool isRemindersEnabled;
  final DateTime createdAt;
  final DateTime lastModifiedAt;

  String get fullName => '$firstName $lastName';

  String get initials => '${firstName[0]}${lastName[0]}'.toUpperCase();

  AppUser copyWith({String? firstName, String? lastName, String? email, bool? isRemindersEnabled}) {
    return AppUser(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      isRemindersEnabled: isRemindersEnabled ?? this.isRemindersEnabled,
      createdAt: createdAt,
      lastModifiedAt: lastModifiedAt,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      email: json['email'] as String,
      isRemindersEnabled: json['is_reminders_enabled'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastModifiedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
}
