import 'package:riverpod_annotation/riverpod_annotation.dart';

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
  return const StaticProfileRepository();
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
  void save(AppUser updated) => state = AsyncData(updated);
}

/// Every Member the current User is associated with (Self or Guardian) —
/// "household" matches the word Today/Challenge/Guide already use for the
/// same John+Jack+Thomas group. In-memory edits reset on app restart, same
/// as ChallengeProgress/EventRsvp.
@riverpod
class HouseholdMembers extends _$HouseholdMembers {
  @override
  Future<List<Member>> build() {
    return ref.watch(profileRepositoryProvider).fetchMembers();
  }

  void upsert(Member member) {
    final current = state.value ?? const [];
    final exists = current.any((m) => m.id == member.id);
    state = AsyncData(
      exists ? [for (final m in current) m.id == member.id ? member : m] : [...current, member],
    );
  }

  void remove(String memberId) {
    final current = state.value ?? const [];
    state = AsyncData(current.where((m) => m.id != memberId).toList());
  }
}

@riverpod
class HouseholdAssociations extends _$HouseholdAssociations {
  @override
  Future<List<UserMemberAssociation>> build() {
    return ref.watch(profileRepositoryProvider).fetchAssociations();
  }

  void addGuardianAssociation(String userId, String memberId) {
    final current = state.value ?? const [];
    state = AsyncData([
      ...current,
      UserMemberAssociation(userId: userId, memberId: memberId, relationship: AssociationRelationship.guardian),
    ]);
  }

  void remove(String memberId) {
    final current = state.value ?? const [];
    state = AsyncData(current.where((a) => a.memberId != memberId).toList());
  }
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

  void toggle(String reminderId) {
    final current = state.value ?? const [];
    state = AsyncData([
      for (final group in current)
        ReminderGroup(
          title: group.title,
          reminders: [
            for (final r in group.reminders) r.id == reminderId ? r.copyWith(enabled: !r.enabled) : r,
          ],
        ),
    ]);
  }
}
