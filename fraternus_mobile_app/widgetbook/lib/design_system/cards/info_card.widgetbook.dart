import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/cards/info_card.dart';

@widgetbook.UseCase(name: 'Basic', type: InfoCard)
Widget basicUseCase(BuildContext context) {
  return const InfoCard(title: 'Jack Thompson', subtitle: 'Age 9');
}

@widgetbook.UseCase(name: 'With avatar initials', type: InfoCard)
Widget withAvatarUseCase(BuildContext context) {
  return const InfoCard(initials: 'JT', title: 'Jack Thompson', subtitle: 'Age 9');
}

@widgetbook.UseCase(name: 'With badge', type: InfoCard)
Widget withBadgeUseCase(BuildContext context) {
  return const InfoCard(
    initials: 'PB',
    title: 'Patrick Brady',
    subtitle: 'Oak Chapter',
    badge: 'Captain',
  );
}

@widgetbook.UseCase(name: 'With remove button', type: InfoCard)
Widget withRemoveUseCase(BuildContext context) {
  return InfoCard(
    initials: 'JT',
    title: 'Jack Thompson',
    subtitle: 'Age 9',
    onRemove: () {},
  );
}
