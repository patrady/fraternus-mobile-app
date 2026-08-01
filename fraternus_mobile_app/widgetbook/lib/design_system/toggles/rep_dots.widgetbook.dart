import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/toggles/rep_dots.dart';

@widgetbook.UseCase(name: 'View-only (partial done)', type: RepDots)
Widget viewOnlyUseCase(BuildContext context) {
  return const RepDots(reps: 5, doneCount: 2);
}

@widgetbook.UseCase(name: 'Editable (tappable)', type: RepDots)
Widget editableUseCase(BuildContext context) {
  return RepDots(reps: 5, doneCount: 3, editable: true, onToggle: (_) {});
}
