import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/layout/hairline_divider.dart';

@widgetbook.UseCase(name: 'Default', type: HairlineDivider)
Widget defaultUseCase(BuildContext context) {
  return const SizedBox(width: 320, child: HairlineDivider());
}
