import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/icons/fraternus_icons.dart';
import 'package:fraternus_mobile_app/design_system/tags/tag.dart';

@widgetbook.UseCase(name: 'Playground', type: Tag)
Widget playgroundUseCase(BuildContext context) {
  return Center(
    child: Tag(
      label: context.knobs.string(label: 'Label', initialValue: 'New'),
      color: context.knobs.object.dropdown<TagColor>(
        label: 'Color',
        options: TagColor.values,
        initialOption: TagColor.primary,
        labelBuilder: (value) => value.name,
      ),
      size: context.knobs.object.dropdown<TagSize>(
        label: 'Size',
        options: TagSize.values,
        initialOption: TagSize.medium,
        labelBuilder: (value) => value.name,
      ),
      icon: context.knobs.objectOrNull.dropdown<String?>(
        label: 'Icon',
        options: [null, ...FraternusIcons.byName.keys],
        initialOption: null,
        labelBuilder: (value) => value ?? 'None',
      ),
      iconPosition: context.knobs.object.dropdown<TagIconPosition>(
        label: 'Icon position',
        options: TagIconPosition.values,
        initialOption: TagIconPosition.left,
        labelBuilder: (value) => value.name,
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Colors', type: Tag)
Widget colorsUseCase(BuildContext context) {
  return Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tag(label: 'Primary', color: TagColor.primary, icon: 'sparkles'),
        const SizedBox(width: 12),
        Tag(label: 'Secondary', color: TagColor.secondary),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Sizes', type: Tag)
Widget sizesUseCase(BuildContext context) {
  return Center(
    child: Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Tag(label: 'Small', size: TagSize.small),
        const SizedBox(width: 12),
        Tag(label: 'Medium', size: TagSize.medium),
        const SizedBox(width: 12),
        Tag(label: 'Large', size: TagSize.large),
      ],
    ),
  );
}
