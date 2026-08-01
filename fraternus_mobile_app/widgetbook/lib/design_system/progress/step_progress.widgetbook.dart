import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/progress/step_progress.dart';

@widgetbook.UseCase(name: 'Step 1 of 7', type: StepProgress)
Widget step1UseCase(BuildContext context) {
  return const StepProgress(step: 1, total: 7);
}

@widgetbook.UseCase(name: 'Step 4 of 7', type: StepProgress)
Widget step4UseCase(BuildContext context) {
  return const StepProgress(step: 4, total: 7);
}

@widgetbook.UseCase(name: 'Complete (7 of 7)', type: StepProgress)
Widget completeUseCase(BuildContext context) {
  return const StepProgress(step: 7, total: 7);
}
