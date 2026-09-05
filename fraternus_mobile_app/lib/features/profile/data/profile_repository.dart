import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/app_user.dart';
import '../models/member.dart';
import '../models/reminder_setting.dart';
import '../models/user_member_association.dart';

/// Source of the Profile tab's data. Same seam as every other XRepository —
/// swapping the implementation doesn't change this interface, the
/// providers that watch it, or the screens.
abstract class ProfileRepository {
  Future<AppUser> fetchCurrentUser();
  Future<List<Member>> fetchMembers();
  Future<List<UserMemberAssociation>> fetchAssociations();
  Future<List<ReminderGroup>> fetchReminders();

  Future<void> updateProfile(AppUser user);
  Future<void> updateMember(Member member);

  /// Atomically creates a Brother Member + Guardian association for the
  /// current Guardian. Returns the new Member's id.
  Future<String> createChildMember({
    required String firstName,
    required String lastName,
    required String chapterKey,
    String? email,
  });

  /// Atomically creates a Captain Member + Self association for the
  /// current user. Used by both the Captain signup flow and a Guardian who
  /// also attends meetings — nothing about it is Captain-signup-specific
  /// beyond naming. Returns the new Member's id.
  Future<String> completeCaptainSignup({
    required String chapterKey,
    required String firstName,
    required String lastName,
  });

  /// docs/adrs/003_coppa_child_data_deletion.md — deletes [memberId] and,
  /// via cascade, everything referencing them.
  Future<void> deleteMember(String memberId);

  Future<void> setReminderEnabled(ReminderType type, bool enabled);

  /// The master switch — [AppUser.isRemindersEnabled].
  Future<void> setRemindersEnabled(bool enabled);
}

/// In-memory mutable fake, matching the reference screenshots and the
/// User/Member/UserMemberAssociation shape from docs/app_concept.md. Every
/// write method here actually mutates this instance's state — needed so
/// CurrentUser/HouseholdMembers/ProfileReminders' write-then-invalidate
/// pattern (see profile_providers.dart) has something real to show on the
/// next fetch. Used as the default in tests (see test/widget_test.dart)
/// since there's no live Supabase connection in that environment.
class StaticProfileRepository implements ProfileRepository {
  StaticProfileRepository()
    : _user = _seedUser(),
      _members = _seedMembers(),
      _associations = _seedAssociations(),
      _reminderOverrides = {};

  static const _userId = 'user-john';
  static const _selfEmail = 'john.smith@example.com';

  AppUser _user;
  final List<Member> _members;
  final List<UserMemberAssociation> _associations;

  /// Sparse — matches the real schema's "absence means enabled" rule.
  final Map<ReminderType, bool> _reminderOverrides;

  static AppUser _seedUser() {
    final joinedAt = DateTime.now().subtract(const Duration(days: 400));
    return AppUser(
      id: _userId,
      firstName: 'John',
      lastName: 'Smith',
      email: _selfEmail,
      isRemindersEnabled: true,
      createdAt: joinedAt,
      lastModifiedAt: joinedAt,
    );
  }

  static List<Member> _seedMembers() {
    final now = DateTime.now();
    final joinedAt = now.subtract(const Duration(days: 400));
    return [
      Member(
        id: 'you',
        firstName: 'John',
        lastName: 'Smith',
        role: MemberRole.captain,
        chapterKey: 'st_philips_franklin_franklin_tn',
        email: _selfEmail,
        createdAt: joinedAt,
        lastModifiedAt: joinedAt,
      ),
      Member(
        id: 'jack',
        firstName: 'Jack',
        lastName: 'Smith',
        role: MemberRole.brother,
        chapterKey: 'st_philips_franklin_franklin_tn',
        createdAt: joinedAt,
        lastModifiedAt: joinedAt,
      ),
      Member(
        id: 'thomas',
        firstName: 'Thomas',
        lastName: 'Smith',
        role: MemberRole.brother,
        chapterKey: 'st_philips_franklin_franklin_tn',
        createdAt: joinedAt,
        lastModifiedAt: joinedAt,
      ),
    ];
  }

  static List<UserMemberAssociation> _seedAssociations() {
    final joinedAt = DateTime.now().subtract(const Duration(days: 400));
    return [
      UserMemberAssociation(
        id: '$_userId-you',
        userId: _userId,
        memberId: 'you',
        relationship: AssociationRelationship.self,
        createdAt: joinedAt,
        lastModifiedAt: joinedAt,
      ),
      UserMemberAssociation(
        id: '$_userId-jack',
        userId: _userId,
        memberId: 'jack',
        relationship: AssociationRelationship.guardian,
        createdAt: joinedAt,
        lastModifiedAt: joinedAt,
      ),
      UserMemberAssociation(
        id: '$_userId-thomas',
        userId: _userId,
        memberId: 'thomas',
        relationship: AssociationRelationship.guardian,
        createdAt: joinedAt,
        lastModifiedAt: joinedAt,
      ),
    ];
  }

  @override
  Future<AppUser> fetchCurrentUser() async => _user;

  @override
  Future<List<Member>> fetchMembers() async => List.unmodifiable(_members);

  @override
  Future<List<UserMemberAssociation>> fetchAssociations() async => List.unmodifiable(_associations);

  @override
  Future<List<ReminderGroup>> fetchReminders() async {
    return [
      for (final entry in ReminderGroup.groupedTypes.entries)
        ReminderGroup(
          title: entry.key,
          reminders: [
            for (final type in entry.value) ReminderSetting(type: type, enabled: _reminderOverrides[type] ?? true),
          ],
        ),
    ];
  }

  @override
  Future<void> updateProfile(AppUser user) async {
    _user = user;
  }

  @override
  Future<void> updateMember(Member member) async {
    final index = _members.indexWhere((m) => m.id == member.id);
    if (index == -1) return;
    _members[index] = member;
  }

  @override
  Future<String> createChildMember({
    required String firstName,
    required String lastName,
    required String chapterKey,
    String? email,
  }) async {
    final now = DateTime.now();
    final id = 'child-${now.microsecondsSinceEpoch}';
    _members.add(
      Member(
        id: id,
        firstName: firstName,
        lastName: lastName,
        role: MemberRole.brother,
        chapterKey: chapterKey,
        email: email,
        createdAt: now,
        lastModifiedAt: now,
      ),
    );
    _associations.add(
      UserMemberAssociation(
        id: '$_userId-$id',
        userId: _userId,
        memberId: id,
        relationship: AssociationRelationship.guardian,
        createdAt: now,
        lastModifiedAt: now,
      ),
    );
    return id;
  }

  @override
  Future<String> completeCaptainSignup({
    required String chapterKey,
    required String firstName,
    required String lastName,
  }) async {
    final now = DateTime.now();
    final id = 'self-${now.microsecondsSinceEpoch}';
    _members.add(
      Member(
        id: id,
        firstName: firstName,
        lastName: lastName,
        role: MemberRole.captain,
        chapterKey: chapterKey,
        email: _user.email,
        createdAt: now,
        lastModifiedAt: now,
      ),
    );
    _associations.add(
      UserMemberAssociation(
        id: '$_userId-$id',
        userId: _userId,
        memberId: id,
        relationship: AssociationRelationship.self,
        createdAt: now,
        lastModifiedAt: now,
      ),
    );
    return id;
  }

  @override
  Future<void> deleteMember(String memberId) async {
    _members.removeWhere((m) => m.id == memberId);
    _associations.removeWhere((a) => a.memberId == memberId);
  }

  @override
  Future<void> setReminderEnabled(ReminderType type, bool enabled) async {
    _reminderOverrides[type] = enabled;
  }

  @override
  Future<void> setRemindersEnabled(bool enabled) async {
    _user = _user.copyWith(isRemindersEnabled: enabled);
  }
}

/// Supabase-backed implementation. RLS (see supabase/migrations) enforces
/// that the caller can only read/write their own User row and Members
/// they have a Self or Guardian association with — this repository doesn't
/// re-check that client-side.
class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);

  final SupabaseClient _client;

  String get _userId => _client.auth.currentUser!.id;

  @override
  Future<AppUser> fetchCurrentUser() async {
    final json = await _client.from('users').select().eq('id', _userId).single();
    return AppUser.fromJson(json);
  }

  @override
  Future<List<Member>> fetchMembers() async {
    final rows = await _client.from('user_member_associations').select('members(*)').eq('user_id', _userId);
    return [for (final row in rows) Member.fromJson(row['members'] as Map<String, dynamic>)];
  }

  @override
  Future<List<UserMemberAssociation>> fetchAssociations() async {
    final rows = await _client.from('user_member_associations').select().eq('user_id', _userId);
    return [for (final row in rows) UserMemberAssociation.fromJson(row)];
  }

  @override
  Future<List<ReminderGroup>> fetchReminders() async {
    final rows = await _client.from('user_reminders').select('type, is_enabled').eq('user_id', _userId);
    final overrides = {
      for (final row in rows) ReminderType.fromJson(row['type'] as String): row['is_enabled'] as bool,
    };
    return [
      for (final entry in ReminderGroup.groupedTypes.entries)
        ReminderGroup(
          title: entry.key,
          reminders: [
            for (final type in entry.value) ReminderSetting(type: type, enabled: overrides[type] ?? true),
          ],
        ),
    ];
  }

  @override
  Future<void> updateProfile(AppUser user) async {
    await _client
        .from('users')
        .update({'first_name': user.firstName, 'last_name': user.lastName, 'email': user.email})
        .eq('id', _userId);
  }

  @override
  Future<void> updateMember(Member member) async {
    await _client
        .from('members')
        .update({
          'first_name': member.firstName,
          'last_name': member.lastName,
          'email': member.email,
          'chapter_key': member.chapterKey,
        })
        .eq('id', member.id);
  }

  @override
  Future<String> createChildMember({
    required String firstName,
    required String lastName,
    required String chapterKey,
    String? email,
  }) async {
    final result = await _client.rpc(
      'create_child_member',
      params: {'p_first_name': firstName, 'p_last_name': lastName, 'p_chapter_key': chapterKey, 'p_email': email},
    );
    return result as String;
  }

  @override
  Future<String> completeCaptainSignup({
    required String chapterKey,
    required String firstName,
    required String lastName,
  }) async {
    final result = await _client.rpc(
      'complete_captain_signup',
      params: {'p_chapter_key': chapterKey, 'p_first_name': firstName, 'p_last_name': lastName},
    );
    return result as String;
  }

  @override
  Future<void> deleteMember(String memberId) async {
    await _client.rpc('delete_member_data', params: {'target_member_id': memberId});
  }

  @override
  Future<void> setReminderEnabled(ReminderType type, bool enabled) async {
    await _client.from('user_reminders').upsert({
      'type': type.toJson(),
      'is_enabled': enabled,
    }, onConflict: 'user_id,type');
  }

  @override
  Future<void> setRemindersEnabled(bool enabled) async {
    await _client.from('users').update({'is_reminders_enabled': enabled}).eq('id', _userId);
  }
}
