import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/cards/dark_feature_card.dart';

@widgetbook.UseCase(name: 'With icon + CTA', type: DarkFeatureCard)
Widget withCtaUseCase(BuildContext context) {
  return DarkFeatureCard(
    icon: 'award',
    eyebrow: 'Your Temperament',
    value: 'The Choleric',
    body: 'Driven, decisive, and quick to lead.',
    ctaLabel: 'Retake Quiz',
    onCta: () {},
  );
}

@widgetbook.UseCase(name: 'Without CTA', type: DarkFeatureCard)
Widget withoutCtaUseCase(BuildContext context) {
  return const DarkFeatureCard(
    icon: 'party-popper',
    eyebrow: 'Challenge Complete!',
    value: 'Great Work',
    body: 'You finished all 5 reps this week.',
  );
}

@widgetbook.UseCase(name: 'Minimal (value only)', type: DarkFeatureCard)
Widget minimalUseCase(BuildContext context) {
  return const DarkFeatureCard(value: 'The Choleric');
}
