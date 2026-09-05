// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'selected_household_member_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Which household member (You/Jack/Thomas) is active in the Today/Field
/// Guide/Challenge tabs' [PersonTabs] switcher. Shared across all three
/// features so picking a child on one tab keeps them selected on the
/// others — each screen still does its own reconciliation against its
/// household list (falling back to the first member) since the default
/// 'you' won't match a real Member id for a Guardian with no Self record.

@ProviderFor(SelectedHouseholdMember)
const selectedHouseholdMemberProvider = SelectedHouseholdMemberProvider._();

/// Which household member (You/Jack/Thomas) is active in the Today/Field
/// Guide/Challenge tabs' [PersonTabs] switcher. Shared across all three
/// features so picking a child on one tab keeps them selected on the
/// others — each screen still does its own reconciliation against its
/// household list (falling back to the first member) since the default
/// 'you' won't match a real Member id for a Guardian with no Self record.
final class SelectedHouseholdMemberProvider
    extends $NotifierProvider<SelectedHouseholdMember, String> {
  /// Which household member (You/Jack/Thomas) is active in the Today/Field
  /// Guide/Challenge tabs' [PersonTabs] switcher. Shared across all three
  /// features so picking a child on one tab keeps them selected on the
  /// others — each screen still does its own reconciliation against its
  /// household list (falling back to the first member) since the default
  /// 'you' won't match a real Member id for a Guardian with no Self record.
  const SelectedHouseholdMemberProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedHouseholdMemberProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedHouseholdMemberHash();

  @$internal
  @override
  SelectedHouseholdMember create() => SelectedHouseholdMember();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$selectedHouseholdMemberHash() =>
    r'397216011a6db7b8d9655b04c1818a3f470fe8b5';

/// Which household member (You/Jack/Thomas) is active in the Today/Field
/// Guide/Challenge tabs' [PersonTabs] switcher. Shared across all three
/// features so picking a child on one tab keeps them selected on the
/// others — each screen still does its own reconciliation against its
/// household list (falling back to the first member) since the default
/// 'you' won't match a real Member id for a Guardian with no Self record.

abstract class _$SelectedHouseholdMember extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
