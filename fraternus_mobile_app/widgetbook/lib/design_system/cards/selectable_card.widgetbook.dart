import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/cards/selectable_card.dart';

@widgetbook.UseCase(name: 'Unselected', type: SelectableCard)
Widget unselectedUseCase(BuildContext context) {
  return SelectableCard(
    icon: 'users',
    title: 'Parent or Volunteer',
    description: 'I have a child in Fraternus, or I help lead a chapter.',
    onPressed: () {},
  );
}

@widgetbook.UseCase(name: 'Selected', type: SelectableCard)
Widget selectedUseCase(BuildContext context) {
  return SelectableCard(
    icon: 'users',
    title: 'Parent or Volunteer',
    description: 'I have a child in Fraternus, or I help lead a chapter.',
    selected: true,
    onPressed: () {},
  );
}

@widgetbook.UseCase(name: 'Muted (locked)', type: SelectableCard)
Widget mutedUseCase(BuildContext context) {
  return SelectableCard(
    icon: 'compass',
    title: 'Brother',
    description: 'Coming soon — brothers will sign in through their chapter.',
    muted: true,
    onPressed: () {},
  );
}
