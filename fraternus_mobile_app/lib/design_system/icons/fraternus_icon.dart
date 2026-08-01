import 'package:flutter/widgets.dart';

import '../tokens/fraternus_colors.dart';
import 'fraternus_icons.dart';

enum FraternusIconTone { ink, white, terracotta, error, success }

extension on FraternusIconTone {
  Color get color => switch (this) {
    FraternusIconTone.ink => FraternusColors.ink,
    FraternusIconTone.white => FraternusColors.white,
    FraternusIconTone.terracotta => FraternusColors.terracotta,
    FraternusIconTone.error => FraternusColors.error,
    FraternusIconTone.success => FraternusColors.success,
  };
}

/// Ports design_handoff_components/icons.jsx's `<Icon />` helper.
class FraternusIcon extends StatelessWidget {
  const FraternusIcon({
    super.key,
    required this.name,
    this.tone = FraternusIconTone.ink,
    this.size = 20,
    this.opacity = 1,
  });

  final String name;
  final FraternusIconTone tone;
  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Icon(FraternusIcons.resolve(name), size: size, color: tone.color),
    );
  }
}
