import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/tokens/fraternus_typography.dart';
import 'package:fraternus_mobile_app/design_system/forms/field_label.dart';
import 'package:fraternus_mobile_app/design_system/forms/form_card.dart';

Widget _fields() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const FieldLabel(label: 'First Name'),
      Text('Jack', style: FraternusTypography.body()),
      const SizedBox(height: 12),
      const FieldLabel(label: 'Age'),
      Text('9', style: FraternusTypography.body()),
    ],
  );
}

@widgetbook.UseCase(name: 'Save disabled', type: FormCard)
Widget saveDisabledUseCase(BuildContext context) {
  return FormCard(canSave: false, onCancel: () {}, onSave: () {}, child: _fields());
}

@widgetbook.UseCase(name: 'Save enabled', type: FormCard)
Widget saveEnabledUseCase(BuildContext context) {
  return FormCard(canSave: true, onCancel: () {}, onSave: () {}, child: _fields());
}

@widgetbook.UseCase(name: 'Custom save label', type: FormCard)
Widget customSaveLabelUseCase(BuildContext context) {
  return FormCard(
    canSave: true,
    saveLabel: 'Add Child',
    onCancel: () {},
    onSave: () {},
    child: _fields(),
  );
}
