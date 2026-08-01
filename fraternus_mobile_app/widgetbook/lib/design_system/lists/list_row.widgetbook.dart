import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/avatar/avatar.dart';
import 'package:fraternus_mobile_app/design_system/icons/fraternus_icon.dart';
import 'package:fraternus_mobile_app/design_system/lists/list_row.dart';

@widgetbook.UseCase(name: 'Bordered w/ chevron', type: ListRow)
Widget borderedChevronUseCase(BuildContext context) {
  return ListRow(
    leading: const Avatar(initials: 'JT', size: .small),
    label: 'Jack Thompson',
    sublabel: 'Age 9',
    onPressed: () {},
  );
}

@widgetbook.UseCase(name: 'Bordered w/ trailing control', type: ListRow)
Widget borderedTrailingUseCase(BuildContext context) {
  return ListRow(
    leading: const FraternusIcon(name: 'circle-user'),
    label: 'Edit Profile',
    trailing: const FraternusIcon(name: 'circle-check', tone: FraternusIconTone.success),
    onPressed: () {},
  );
}

@widgetbook.UseCase(name: 'Unbordered plain', type: ListRow)
Widget unborderedUseCase(BuildContext context) {
  return ListRow(label: 'Read today\'s reflection', bordered: false, onPressed: () {});
}

@widgetbook.UseCase(name: 'No chevron', type: ListRow)
Widget noChevronUseCase(BuildContext context) {
  return const ListRow(label: 'Reminder notifications', chevron: false);
}
