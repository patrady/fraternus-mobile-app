import 'package:flutter_test/flutter_test.dart';
import 'package:fraternus_mobile_app/features/profile/models/app_user.dart';

void main() {
  final json = {
    'id': 'user-1',
    'first_name': 'John',
    'last_name': 'Smith',
    'email': 'john@example.com',
    'is_reminders_enabled': true,
    'created_at': '2026-01-01T00:00:00Z',
    'updated_at': '2026-01-02T00:00:00Z',
  };

  test('AppUser.fromJson maps every field', () {
    final user = AppUser.fromJson(json);

    expect(user.id, 'user-1');
    expect(user.firstName, 'John');
    expect(user.lastName, 'Smith');
    expect(user.email, 'john@example.com');
    expect(user.isRemindersEnabled, isTrue);
    expect(user.createdAt, DateTime.parse('2026-01-01T00:00:00Z'));
    expect(user.lastModifiedAt, DateTime.parse('2026-01-02T00:00:00Z'));
  });

  test('fullName and initials derive from first/last name', () {
    final user = AppUser.fromJson(json);
    expect(user.fullName, 'John Smith');
    expect(user.initials, 'JS');
  });

  test('copyWith leaves unspecified fields untouched', () {
    final user = AppUser.fromJson(json);
    final copy = user.copyWith(firstName: 'Jane');

    expect(copy.firstName, 'Jane');
    expect(copy.lastName, user.lastName);
    expect(copy.email, user.email);
    expect(copy.isRemindersEnabled, user.isRemindersEnabled);
  });
}
