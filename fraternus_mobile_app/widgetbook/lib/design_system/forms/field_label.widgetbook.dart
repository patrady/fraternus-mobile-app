import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/forms/field_label.dart';

@widgetbook.UseCase(name: 'Default', type: FieldLabel)
Widget defaultUseCase(BuildContext context) {
  return const FieldLabel(label: 'Email');
}
