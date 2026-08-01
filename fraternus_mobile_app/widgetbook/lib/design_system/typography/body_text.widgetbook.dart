import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/tokens/fraternus_colors.dart';
import 'package:fraternus_mobile_app/design_system/typography/body_text.dart';

@widgetbook.UseCase(name: 'Playground', type: BodyText)
Widget playgroundUseCase(BuildContext context) {
  final onDark = context.knobs.boolean(label: 'On dark', initialValue: false);

  final body = BodyText(
    context.knobs.string(
      label: 'Text',
      initialValue: 'Every man carries a mountain he must climb.',
      maxLines: 3,
    ),
    size: context.knobs.object.dropdown<BodyTextSize>(
      label: 'Size',
      options: BodyTextSize.values,
      initialOption: BodyTextSize.base,
      labelBuilder: (value) => value.name,
    ),
    onDark: onDark,
  );

  return Center(
    child: onDark
        ? Container(color: FraternusColors.surfaceDark, padding: const EdgeInsets.all(20), child: body)
        : body,
  );
}

@widgetbook.UseCase(name: 'Sizes', type: BodyText)
Widget sizesUseCase(BuildContext context) {
  return const Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BodyText('Body large', size: BodyTextSize.large),
        SizedBox(height: 8),
        BodyText('Body base', size: BodyTextSize.base),
        SizedBox(height: 8),
        BodyText('Body small', size: BodyTextSize.small),
        SizedBox(height: 8),
        BodyText('Body caption', size: BodyTextSize.caption),
      ],
    ),
  );
}
