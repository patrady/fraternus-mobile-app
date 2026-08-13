import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/cards/dark_summary_card.dart';

@widgetbook.UseCase(name: "This Week's Focus", type: DarkSummaryCard)
Widget defaultUseCase(BuildContext context) {
  return DarkSummaryCard(eyebrow: "This Week's Focus", title: 'Humility', onPressed: () {});
}
