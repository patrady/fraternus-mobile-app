import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'selected_household_member_provider.g.dart';

/// Which household member (You/Jack/Thomas) is active in the Today/Field
/// Guide/Challenge tabs' [PersonTabs] switcher. Shared across all three
/// features so picking a child on one tab keeps them selected on the
/// others — each screen still does its own reconciliation against its
/// household list (falling back to the first member) since the default
/// 'you' won't match a real Member id for a Guardian with no Self record.
@riverpod
class SelectedHouseholdMember extends _$SelectedHouseholdMember {
  @override
  String build() => 'you';

  void select(String key) => state = key;
}
