import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/progress/continuous_progress_bar.dart';

@widgetbook.UseCase(name: 'Early', type: ContinuousProgressBar)
Widget earlyUseCase(BuildContext context) {
  return const ContinuousProgressBar(index: 0, total: 8);
}

@widgetbook.UseCase(name: 'Mid', type: ContinuousProgressBar)
Widget midUseCase(BuildContext context) {
  return const ContinuousProgressBar(index: 3, total: 8);
}

@widgetbook.UseCase(name: 'Near complete', type: ContinuousProgressBar)
Widget nearCompleteUseCase(BuildContext context) {
  return const ContinuousProgressBar(index: 7, total: 8);
}
