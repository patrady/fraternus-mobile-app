import 'package:flutter/widgets.dart';

import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';

enum BoxColor { plain, primary, secondary }

/// Generic surface container — the shared building block behind cards,
/// panels and sections that just need a background, padding and rounded
/// corners without any content opinions of their own.
class Box extends StatelessWidget {
  const Box({
    super.key,
    required this.child,
    this.color = BoxColor.plain,
    this.padding = const EdgeInsets.all(FraternusSpacing.space2),
    this.borderRadius = FraternusRadii.lg,
  });

  final Widget child;
  final BoxColor color;
  final EdgeInsets padding;
  final double borderRadius;

  Color get _background => switch (color) {
    BoxColor.plain => FraternusColors.surfaceCardLight,
    BoxColor.primary => FraternusColors.surfaceDark,
    BoxColor.secondary => FraternusColors.surfaceCardDim,
  };

  Border? get _border => switch (color) {
    BoxColor.plain => Border.all(color: FraternusColors.borderSubtle),
    BoxColor.primary || BoxColor.secondary => null,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: _background,
        border: _border,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: child,
    );
  }
}
