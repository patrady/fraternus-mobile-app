import 'package:flutter/widgets.dart';

import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_typography.dart';

enum BodyTextSize { large, base, small, caption }

/// Paragraph/body copy. Wraps [FraternusTypography]'s bodyLg/body/small/
/// caption tokens.
class BodyText extends StatelessWidget {
  const BodyText(
    this.text, {
    super.key,
    this.size = BodyTextSize.base,
    this.onDark = false,
    this.align = TextAlign.start,
  });

  final String text;
  final BodyTextSize size;
  final bool onDark;
  final TextAlign align;

  Color get _color =>
      onDark ? FraternusColors.textOnDarkMuted : FraternusColors.textOnLight;

  TextStyle get _style => switch (size) {
    BodyTextSize.large => FraternusTypography.bodyLg(color: _color),
    BodyTextSize.base => FraternusTypography.body(color: _color),
    BodyTextSize.small => FraternusTypography.small(color: _color),
    BodyTextSize.caption => FraternusTypography.caption(color: _color),
  };

  @override
  Widget build(BuildContext context) =>
      Text(text, textAlign: align, style: _style);
}
