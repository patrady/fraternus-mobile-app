import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/tokens/fraternus_colors.dart';
import 'package:fraternus_mobile_app/design_system/icons/fraternus_icon.dart';

@widgetbook.UseCase(name: 'Tone sweep', type: FraternusIcon)
Widget toneSweepUseCase(BuildContext context) {
  return Container(
    padding: const EdgeInsets.all(16),
    color: FraternusColors.parchmentDim,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        FraternusIcon(name: 'circle-check', tone: FraternusIconTone.ink),
        SizedBox(width: 16),
        FraternusIcon(name: 'circle-check', tone: FraternusIconTone.terracotta),
        SizedBox(width: 16),
        FraternusIcon(name: 'circle-check', tone: FraternusIconTone.error),
        SizedBox(width: 16),
        FraternusIcon(name: 'circle-check', tone: FraternusIconTone.success),
        SizedBox(width: 16),
        ColoredBox(
          color: FraternusColors.forestGreen,
          child: Padding(
            padding: EdgeInsets.all(4),
            child: FraternusIcon(name: 'circle-check', tone: FraternusIconTone.white),
          ),
        ),
      ],
    ),
  );
}
