import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/tokens/fraternus_colors.dart';
import 'package:fraternus_mobile_app/design_system/typography/heading.dart';

@widgetbook.UseCase(name: 'Playground', type: Heading)
Widget playgroundUseCase(BuildContext context) {
  final onDark = context.knobs.boolean(label: 'On dark', initialValue: false);

  final heading = Heading(
    context.knobs.string(label: 'Text', initialValue: 'The Man in the Mirror'),
    level: context.knobs.object.dropdown<HeadingLevel>(
      label: 'Level',
      options: HeadingLevel.values,
      initialOption: HeadingLevel.h2,
      labelBuilder: (value) => value.name,
    ),
    onDark: onDark,
  );

  return Center(
    child: onDark
        ? Container(color: FraternusColors.surfaceDark, padding: const EdgeInsets.all(20), child: heading)
        : heading,
  );
}

@widgetbook.UseCase(name: 'Levels', type: Heading)
Widget levelsUseCase(BuildContext context) {
  return const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Heading('Heading 1', level: HeadingLevel.h1),
        SizedBox(height: 12),
        Heading('Heading 2', level: HeadingLevel.h2),
        SizedBox(height: 12),
        Heading('Heading 3', level: HeadingLevel.h3),
        SizedBox(height: 12),
        Heading('Heading 4', level: HeadingLevel.h4),
      ],
    ),
  );
}
