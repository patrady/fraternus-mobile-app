import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/avatar/avatar.dart';

@widgetbook.UseCase(name: 'Small', type: Avatar)
Widget smallUseCase(BuildContext context) {
  return const Avatar(initials: 'JT', size: .small);
}

@widgetbook.UseCase(name: 'Medium (Default)', type: Avatar)
Widget defaultUseCase(BuildContext context) {
  return const Avatar(initials: 'JT');
}

@widgetbook.UseCase(name: 'Large', type: Avatar)
Widget largeUseCase(BuildContext context) {
  return const Avatar(initials: 'JT', size: .large);
}
