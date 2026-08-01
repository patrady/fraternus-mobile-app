import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/badges/streak_banner.dart';

@widgetbook.UseCase(name: 'Default count', type: StreakBanner)
Widget defaultUseCase(BuildContext context) {
  return const StreakBanner(count: 12);
}

@widgetbook.UseCase(name: 'Custom label', type: StreakBanner)
Widget customLabelUseCase(BuildContext context) {
  return const StreakBanner(count: 3, label: 'Days In A Row');
}
