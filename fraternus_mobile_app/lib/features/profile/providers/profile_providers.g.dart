// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Swap this provider's implementation to change where Profile's data comes
/// from — nothing downstream needs to change.

@ProviderFor(profileRepository)
const profileRepositoryProvider = ProfileRepositoryProvider._();

/// Swap this provider's implementation to change where Profile's data comes
/// from — nothing downstream needs to change.

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  /// Swap this provider's implementation to change where Profile's data comes
  /// from — nothing downstream needs to change.
  const ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'f251b6c9b7ba03ff45e660eafeb575f03c60080e';

@ProviderFor(CurrentUser)
const currentUserProvider = CurrentUserProvider._();

final class CurrentUserProvider
    extends $AsyncNotifierProvider<CurrentUser, AppUser> {
  const CurrentUserProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentUserProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentUserHash();

  @$internal
  @override
  CurrentUser create() => CurrentUser();
}

String _$currentUserHash() => r'a652ee4743e16f4517fd4f368d42e6693cda0d77';

abstract class _$CurrentUser extends $AsyncNotifier<AppUser> {
  FutureOr<AppUser> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<AppUser>, AppUser>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AppUser>, AppUser>,
              AsyncValue<AppUser>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Every Member the current User is associated with (Self or Guardian) —
/// "household" matches the word Today/Challenge/Guide already use for the
/// same John+Jack+Thomas group.

@ProviderFor(HouseholdMembers)
const householdMembersProvider = HouseholdMembersProvider._();

/// Every Member the current User is associated with (Self or Guardian) —
/// "household" matches the word Today/Challenge/Guide already use for the
/// same John+Jack+Thomas group.
final class HouseholdMembersProvider
    extends $AsyncNotifierProvider<HouseholdMembers, List<Member>> {
  /// Every Member the current User is associated with (Self or Guardian) —
  /// "household" matches the word Today/Challenge/Guide already use for the
  /// same John+Jack+Thomas group.
  const HouseholdMembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'householdMembersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$householdMembersHash();

  @$internal
  @override
  HouseholdMembers create() => HouseholdMembers();
}

String _$householdMembersHash() => r'33a80b02051f86e28298ffafa16c86454c9ba3de';

/// Every Member the current User is associated with (Self or Guardian) —
/// "household" matches the word Today/Challenge/Guide already use for the
/// same John+Jack+Thomas group.

abstract class _$HouseholdMembers extends $AsyncNotifier<List<Member>> {
  FutureOr<List<Member>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<Member>>, List<Member>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Member>>, List<Member>>,
              AsyncValue<List<Member>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// This User's UserMemberAssociation rows. Read-only from the client's
/// perspective now — creation is atomic (create_child_member /
/// complete_captain_signup), and deletion only ever happens via
/// HouseholdMembers.remove's cascade. A plain function provider rather than
/// a Notifier class, since nothing here mutates local state directly
/// anymore.

@ProviderFor(householdAssociations)
const householdAssociationsProvider = HouseholdAssociationsProvider._();

/// This User's UserMemberAssociation rows. Read-only from the client's
/// perspective now — creation is atomic (create_child_member /
/// complete_captain_signup), and deletion only ever happens via
/// HouseholdMembers.remove's cascade. A plain function provider rather than
/// a Notifier class, since nothing here mutates local state directly
/// anymore.

final class HouseholdAssociationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<UserMemberAssociation>>,
          List<UserMemberAssociation>,
          FutureOr<List<UserMemberAssociation>>
        >
    with
        $FutureModifier<List<UserMemberAssociation>>,
        $FutureProvider<List<UserMemberAssociation>> {
  /// This User's UserMemberAssociation rows. Read-only from the client's
  /// perspective now — creation is atomic (create_child_member /
  /// complete_captain_signup), and deletion only ever happens via
  /// HouseholdMembers.remove's cascade. A plain function provider rather than
  /// a Notifier class, since nothing here mutates local state directly
  /// anymore.
  const HouseholdAssociationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'householdAssociationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$householdAssociationsHash();

  @$internal
  @override
  $FutureProviderElement<List<UserMemberAssociation>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<UserMemberAssociation>> create(Ref ref) {
    return householdAssociations(ref);
  }
}

String _$householdAssociationsHash() =>
    r'aa800f8ddf384835eff0da9345b550b17e9681b2';

/// The current User's own Member record (Relationship = Self), or null if
/// they've never attended as a Captain — mirrors app_concept.md's "the
/// Guardian has no Member record of their own" case.

@ProviderFor(selfMember)
const selfMemberProvider = SelfMemberProvider._();

/// The current User's own Member record (Relationship = Self), or null if
/// they've never attended as a Captain — mirrors app_concept.md's "the
/// Guardian has no Member record of their own" case.

final class SelfMemberProvider
    extends $FunctionalProvider<AsyncValue<Member?>, Member?, FutureOr<Member?>>
    with $FutureModifier<Member?>, $FutureProvider<Member?> {
  /// The current User's own Member record (Relationship = Self), or null if
  /// they've never attended as a Captain — mirrors app_concept.md's "the
  /// Guardian has no Member record of their own" case.
  const SelfMemberProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selfMemberProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selfMemberHash();

  @$internal
  @override
  $FutureProviderElement<Member?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Member?> create(Ref ref) {
    return selfMember(ref);
  }
}

String _$selfMemberHash() => r'40e0a514d63d668ce62fe8f015d84d917aa08bc3';

/// Members linked via Relationship = Guardian — the "My Kids" list.

@ProviderFor(guardianMembers)
const guardianMembersProvider = GuardianMembersProvider._();

/// Members linked via Relationship = Guardian — the "My Kids" list.

final class GuardianMembersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Member>>,
          List<Member>,
          FutureOr<List<Member>>
        >
    with $FutureModifier<List<Member>>, $FutureProvider<List<Member>> {
  /// Members linked via Relationship = Guardian — the "My Kids" list.
  const GuardianMembersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'guardianMembersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$guardianMembersHash();

  @$internal
  @override
  $FutureProviderElement<List<Member>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Member>> create(Ref ref) {
    return guardianMembers(ref);
  }
}

String _$guardianMembersHash() => r'9532060c88ad8eabb9ce241bc4e1b13f910aee07';

@ProviderFor(ProfileReminders)
const profileRemindersProvider = ProfileRemindersProvider._();

final class ProfileRemindersProvider
    extends $AsyncNotifierProvider<ProfileReminders, List<ReminderGroup>> {
  const ProfileRemindersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRemindersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRemindersHash();

  @$internal
  @override
  ProfileReminders create() => ProfileReminders();
}

String _$profileRemindersHash() => r'db3d8bf0f6cf44a3b33663ad4691776620d85111';

abstract class _$ProfileReminders extends $AsyncNotifier<List<ReminderGroup>> {
  FutureOr<List<ReminderGroup>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<ReminderGroup>>, List<ReminderGroup>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ReminderGroup>>, List<ReminderGroup>>,
              AsyncValue<List<ReminderGroup>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
