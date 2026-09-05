import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../app/supabase_provider.dart';
import '../data/profile_repository.dart';
import '../models/app_user.dart';
import '../models/member.dart';
import '../models/reminder_setting.dart';
import '../models/user_member_association.dart';

part 'profile_providers.g.dart';

/// Swap this provider's implementation to change where Profile's data comes
/// from — nothing downstream needs to change.
@riverpod
ProfileRepository profileRepository(Ref ref) {
  return SupabaseProfileRepository(ref.watch(supabaseClientProvider));
}

@riverpod
class CurrentUser extends _$CurrentUser {
  @override
  Future<AppUser> build() {
    return ref.watch(profileRepositoryProvider).fetchCurrentUser();
  }

  // Named `save` rather than `update` — AsyncNotifier already defines an
  // `update(FutureOr<T> Function(T)) -> Future<T>` method, which this would
  // otherwise collide with.
  Future<void> save(AppUser updated) async {
    await ref.read(profileRepositoryProvider).updateProfile(updated);
    ref.invalidateSelf();
  }

  /// The master reminders switch — [AppUser.isRemindersEnabled].
  Future<void> toggleRemindersEnabled() async {
    final current = state.value;
    if (current == null) return;
    await ref.read(profileRepositoryProvider).setRemindersEnabled(!current.isRemindersEnabled);
    ref.invalidateSelf();
  }
}

/// Every Member the current User is associated with (Self or Guardian) —
/// "household" matches the word Today/Challenge/Guide already use for the
/// same John+Jack+Thomas group.
@riverpod
class HouseholdMembers extends _$HouseholdMembers {
  @override
  Future<List<Member>> build() {
    return ref.watch(profileRepositoryProvider).fetchMembers();
  }

  /// Editing an existing household member. Creating a new child is a
  /// separate, atomic operation (createChildMember, called directly from
  /// the Add Child screen) — not this method, since there's no
  /// pre-existing Member to update. Named `updateMember`, not `update` —
  /// AsyncNotifier already defines its own generic `update` method, which
  /// this would otherwise collide with (same reason CurrentUser's method is
  /// `save`, not `update`).
  Future<void> updateMember(Member member) async {
    await ref.read(profileRepositoryProvider).updateMember(member);
    ref.invalidateSelf();
  }

  /// docs/adrs/003_coppa_child_data_deletion.md — deletes the Member and,
  /// via cascade, everything referencing them (including their
  /// UserMemberAssociation row, so householdAssociationsProvider needs
  /// invalidating too).
  Future<void> remove(String memberId) async {
    await ref.read(profileRepositoryProvider).deleteMember(memberId);
    ref.invalidateSelf();
    ref.invalidate(householdAssociationsProvider);
  }
}

/// This User's UserMemberAssociation rows. Read-only from the client's
/// perspective now — creation is atomic (create_child_member /
/// complete_captain_signup), and deletion only ever happens via
/// HouseholdMembers.remove's cascade. A plain function provider rather than
/// a Notifier class, since nothing here mutates local state directly
/// anymore.
@riverpod
Future<List<UserMemberAssociation>> householdAssociations(Ref ref) {
  return ref.watch(profileRepositoryProvider).fetchAssociations();
}

/// The current User's own Member record (Relationship = Self), or null if
/// they've never attended as a Captain — mirrors app_concept.md's "the
/// Guardian has no Member record of their own" case.
@riverpod
Future<Member?> selfMember(Ref ref) async {
  final members = await ref.watch(householdMembersProvider.future);
  final associations = await ref.watch(householdAssociationsProvider.future);

  String? selfId;
  for (final association in associations) {
    if (association.relationship == AssociationRelationship.self) {
      selfId = association.memberId;
      break;
    }
  }
  if (selfId == null) return null;

  for (final member in members) {
    if (member.id == selfId) return member;
  }
  return null;
}

/// Members linked via Relationship = Guardian — the "My Kids" list.
@riverpod
Future<List<Member>> guardianMembers(Ref ref) async {
  final members = await ref.watch(householdMembersProvider.future);
  final associations = await ref.watch(householdAssociationsProvider.future);

  final guardianIds = <String>{};
  for (final association in associations) {
    if (association.relationship == AssociationRelationship.guardian) {
      guardianIds.add(association.memberId);
    }
  }
  return members.where((m) => guardianIds.contains(m.id)).toList();
}

@riverpod
class ProfileReminders extends _$ProfileReminders {
  @override
  Future<List<ReminderGroup>> build() {
    return ref.watch(profileRepositoryProvider).fetchReminders();
  }

  Future<void> toggle(ReminderType type) async {
    final current = state.value ?? const [];
    ReminderSetting? existing;
    for (final group in current) {
      for (final reminder in group.reminders) {
        if (reminder.type == type) {
          existing = reminder;
          break;
        }
      }
    }
    if (existing == null) return;
    await ref.read(profileRepositoryProvider).setReminderEnabled(type, !existing.enabled);
    ref.invalidateSelf();
  }
}
