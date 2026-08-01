import 'package:flutter/widgets.dart';

import '../tokens/fraternus_colors.dart';
import 'fraternus_icon.dart';

enum IconBadgeCircleSize { small, medium, large }

enum IconBadgeCircleColor { primary, secondary }

/// Centered circular icon badge used for confirmation/status moments —
/// "Check Your Email", "We Love The Enthusiasm", "You're All Set". Ports
/// components-source.jsx `IconBadgeCircle`.
class IconBadgeCircle extends StatelessWidget {
  const IconBadgeCircle({
    super.key,
    required this.icon,
    this.size = IconBadgeCircleSize.medium,
    this.color = IconBadgeCircleColor.primary,
  });

  final String icon;
  final IconBadgeCircleSize size;
  final IconBadgeCircleColor color;

  double get _diameter => switch (size) {
    IconBadgeCircleSize.small => 40.0,
    IconBadgeCircleSize.medium => 56.0,
    IconBadgeCircleSize.large => 72.0,
  };

  double get _iconSize => switch (size) {
    IconBadgeCircleSize.small => 18.0,
    IconBadgeCircleSize.medium => 28.0,
    IconBadgeCircleSize.large => 36.0,
  };

  Color get _background => switch (color) {
    IconBadgeCircleColor.primary => FraternusColors.surfaceDark,
    IconBadgeCircleColor.secondary => FraternusColors.surfaceCardDim,
  };

  FraternusIconTone get _iconTone => switch (color) {
    IconBadgeCircleColor.primary => FraternusIconTone.white,
    IconBadgeCircleColor.secondary => FraternusIconTone.ink,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: _diameter,
      height: _diameter,
      decoration: BoxDecoration(shape: BoxShape.circle, color: _background),
      alignment: Alignment.center,
      child: FraternusIcon(name: icon, size: _iconSize, tone: _iconTone),
    );
  }
}
