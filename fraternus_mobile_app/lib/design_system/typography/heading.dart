import 'package:flutter/widgets.dart';

import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_typography.dart';

enum HeadingLevel { h1, h2, h3, h4 }

/// Display heading — screen titles (h1/h2) down to card/section titles
/// (h3/h4). Wraps [FraternusTypography]'s h1–h4 tokens.
class Heading extends StatelessWidget {
  const Heading(
    this.text, {
    super.key,
    this.level = HeadingLevel.h2,
    this.onDark = false,
    this.align = TextAlign.start,
  });

  final String text;
  final HeadingLevel level;
  final bool onDark;
  final TextAlign align;

  Color get _color => onDark ? FraternusColors.textOnDark : FraternusColors.textOnLight;

  TextStyle get _style => switch (level) {
    HeadingLevel.h1 => FraternusTypography.h1(color: _color),
    HeadingLevel.h2 => FraternusTypography.h2(color: _color),
    HeadingLevel.h3 => FraternusTypography.h3(color: _color),
    HeadingLevel.h4 => FraternusTypography.h4(color: _color),
  };

  @override
  Widget build(BuildContext context) => Text(text, textAlign: align, style: _style);
}
