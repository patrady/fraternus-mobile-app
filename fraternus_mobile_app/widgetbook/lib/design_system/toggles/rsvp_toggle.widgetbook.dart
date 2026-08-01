import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/toggles/rsvp_toggle.dart';

@widgetbook.UseCase(name: 'Unselected', type: RsvpToggle)
Widget unselectedUseCase(BuildContext context) {
  return RsvpToggle(onChanged: (_) {});
}

@widgetbook.UseCase(name: "Going selected", type: RsvpToggle)
Widget goingUseCase(BuildContext context) {
  return RsvpToggle(status: RsvpStatus.yes, onChanged: (_) {});
}

@widgetbook.UseCase(name: "Can't selected", type: RsvpToggle)
Widget cantUseCase(BuildContext context) {
  return RsvpToggle(status: RsvpStatus.no, onChanged: (_) {});
}
