import 'package:flutter/widgets.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/tokens/fraternus_typography.dart';
import 'package:fraternus_mobile_app/design_system/cards/content_card.dart';

@widgetbook.UseCase(name: 'Eyebrow + title + body', type: ContentCard)
Widget eyebrowTitleBodyUseCase(BuildContext context) {
  return ContentCard(
    eyebrow: 'Identity',
    title: "Who You're Made To Be",
    child: Text('Today\'s reading walks through the virtue of fortitude.', style: FraternusTypography.body()),
  );
}

@widgetbook.UseCase(name: 'With italic subtitle/quote', type: ContentCard)
Widget withSubtitleUseCase(BuildContext context) {
  return ContentCard(
    eyebrow: 'Wisdom',
    title: 'Quote of the Day',
    subtitle: '"Courage is not the absence of fear, but the mastery of it."',
    child: Text('Reflect on a time you acted despite fear.', style: FraternusTypography.body()),
  );
}

@widgetbook.UseCase(name: 'With like toggle (liked)', type: ContentCard)
Widget likedUseCase(BuildContext context) {
  return ContentCard(
    eyebrow: 'Section',
    title: 'The Sword',
    liked: true,
    onLike: () {},
    child: Text('Body content goes here.', style: FraternusTypography.body()),
  );
}

@widgetbook.UseCase(name: 'With like toggle (unliked)', type: ContentCard)
Widget unlikedUseCase(BuildContext context) {
  return ContentCard(
    eyebrow: 'Section',
    title: 'The Sword',
    onLike: () {},
    child: Text('Body content goes here.', style: FraternusTypography.body()),
  );
}
