import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/tokens/fraternus_colors.dart';
import 'package:fraternus_mobile_app/design_system/tokens/fraternus_typography.dart';
import 'package:fraternus_mobile_app/design_system/layout/box.dart';

@widgetbook.UseCase(name: 'Playground', type: Box)
Widget playgroundUseCase(BuildContext context) {
  final color = context.knobs.object.dropdown<BoxColor>(
    label: 'Color',
    options: BoxColor.values,
    initialOption: BoxColor.plain,
    labelBuilder: (value) => value.name,
  );

  return Center(
    child: Box(
      color: color,
      child: Text(
        'Box content',
        style: FraternusTypography.body(
          color: color == BoxColor.primary ? FraternusColors.white : FraternusColors.ink,
        ),
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Colors', type: Box)
Widget colorsUseCase(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Box(
          child: Text('Plain', style: FraternusTypography.body(color: FraternusColors.ink)),
        ),
        const SizedBox(height: 12),
        Box(
          color: BoxColor.primary,
          child: Text('Primary', style: FraternusTypography.body(color: FraternusColors.white)),
        ),
        const SizedBox(height: 12),
        Box(
          color: BoxColor.secondary,
          child: Text('Secondary', style: FraternusTypography.body(color: FraternusColors.ink)),
        ),
      ],
    ),
  );
}
