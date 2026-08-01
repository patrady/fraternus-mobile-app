import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/typography/subheading.dart';

@widgetbook.UseCase(name: 'Playground', type: Subheading)
Widget playgroundUseCase(BuildContext context) {
  return Center(
    child: Subheading(context.knobs.string(label: 'Text', initialValue: 'This Week')),
  );
}
