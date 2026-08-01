import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/layout/screen_header.dart';

@widgetbook.UseCase(name: 'Default', type: ScreenHeader)
Widget defaultUseCase(BuildContext context) {
  return ScreenHeader(title: 'Create Account', onBack: () {});
}
