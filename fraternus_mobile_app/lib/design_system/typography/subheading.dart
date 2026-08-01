import 'package:flutter/widgets.dart';

import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_typography.dart';

/// Uppercase kicker label placed above a [Heading] — "GUIDE", "TODAY",
/// eyebrow text on cards. Brand terracotta reads on both light and dark
/// surfaces, so there's no separate on-dark treatment.
class Subheading extends StatelessWidget {
  const Subheading(this.text, {super.key, this.align = TextAlign.start});

  final String text;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      textAlign: align,
      style: FraternusTypography.eyebrow(color: FraternusColors.accentPrimary),
    );
  }
}
