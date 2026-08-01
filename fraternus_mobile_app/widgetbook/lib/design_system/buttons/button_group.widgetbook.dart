import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/buttons/button.dart';
import 'package:fraternus_mobile_app/design_system/buttons/button_group.dart';

@widgetbook.UseCase(name: 'Two buttons', type: ButtonGroup)
Widget twoButtonsUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: ButtonGroup(
      children: [
        Button(label: 'Cancel', variant: ButtonVariant.ghost, onPressed: () {}),
        Button(label: 'Save', onPressed: () {}),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Three buttons', type: ButtonGroup)
Widget threeButtonsUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: ButtonGroup(
      children: [
        Button(label: 'Back', variant: ButtonVariant.ghost, onPressed: () {}),
        Button(label: 'Skip', variant: ButtonVariant.ghost, onPressed: () {}),
        Button(label: 'Continue', onPressed: () {}),
      ],
    ),
  );
}
