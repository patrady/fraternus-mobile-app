import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/avatar/avatar.dart';
import 'package:fraternus_mobile_app/design_system/avatar/avatar_with_badge.dart';
import 'package:fraternus_mobile_app/design_system/avatar/crown_badge.dart';

@widgetbook.UseCase(name: 'Playground', type: AvatarWithBadge)
Widget playgroundUseCase(BuildContext context) {
  return Center(
    child: AvatarWithBadge(
      initials: context.knobs.string(label: 'Initials', initialValue: 'JT'),
      size: context.knobs.object.dropdown<AvatarSize>(
        label: 'Size',
        options: AvatarSize.values,
        initialOption: AvatarSize.medium,
        labelBuilder: (value) => value.name,
      ),
      badgeLabel: context.knobs.stringOrNull(
        label: 'Badge label',
        initialValue: 'Commander',
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'No badge', type: AvatarWithBadge)
Widget noBadgeUseCase(BuildContext context) {
  return const Center(child: AvatarWithBadge(initials: 'JT'));
}

@widgetbook.UseCase(name: 'With badge', type: AvatarWithBadge)
Widget withBadgeUseCase(BuildContext context) {
  return const Center(
    child: AvatarWithBadge(initials: 'JT', badgeLabel: 'Commander'),
  );
}

@widgetbook.UseCase(name: 'Kings Messenger (crown)', type: AvatarWithBadge)
Widget crownBadgeUseCase(BuildContext context) {
  return const Center(
    child: AvatarWithBadge(initials: 'JT', badge: CrownBadge()),
  );
}
