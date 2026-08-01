import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/icons/icon_badge_circle.dart';

@widgetbook.UseCase(name: 'Playground', type: IconBadgeCircle)
Widget playgroundUseCase(BuildContext context) {
  return Center(
    child: IconBadgeCircle(
      icon: context.knobs.string(label: 'Icon', initialValue: 'circle-check'),
      size: context.knobs.object.dropdown<IconBadgeCircleSize>(
        label: 'Size',
        options: IconBadgeCircleSize.values,
        initialOption: IconBadgeCircleSize.medium,
        labelBuilder: (value) => value.name,
      ),
      color: context.knobs.object.dropdown<IconBadgeCircleColor>(
        label: 'Color',
        options: IconBadgeCircleColor.values,
        initialOption: IconBadgeCircleColor.primary,
        labelBuilder: (value) => value.name,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Sizes', type: IconBadgeCircle)
Widget sizesUseCase(BuildContext context) {
  return Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconBadgeCircle(icon: 'circle-check', size: IconBadgeCircleSize.small),
        const SizedBox(width: 16),
        IconBadgeCircle(icon: 'circle-check', size: IconBadgeCircleSize.medium),
        const SizedBox(width: 16),
        IconBadgeCircle(icon: 'circle-check', size: IconBadgeCircleSize.large),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Colors', type: IconBadgeCircle)
Widget colorsUseCase(BuildContext context) {
  return Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconBadgeCircle(icon: 'party-popper', color: IconBadgeCircleColor.primary),
        const SizedBox(width: 16),
        IconBadgeCircle(icon: 'party-popper', color: IconBadgeCircleColor.secondary),
      ],
    ),
  );
}
