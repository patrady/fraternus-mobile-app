import 'package:flutter/widgets.dart';

import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';

/// Single animated fill bar for the temperament quiz — as opposed to
/// [StepProgress]'s discrete segments. Ports components-source.jsx
/// `ContinuousProgressBar`.
class ContinuousProgressBar extends StatelessWidget {
  const ContinuousProgressBar({
    super.key,
    required this.index,
    required this.total,
  });

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    final fraction = total == 0 ? 0.0 : ((index + 1) / total).clamp(0.0, 1.0);
    return ClipRRect(
      borderRadius: BorderRadius.circular(FraternusRadii.pill),
      child: Container(
        height: 6,
        color: FraternusColors.borderSubtle,
        alignment: Alignment.centerLeft,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: fraction),
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          builder: (context, value, child) {
            return FractionallySizedBox(
              widthFactor: value,
              child: Container(
                height: 6,
                decoration: BoxDecoration(
                  color: FraternusColors.accentPrimary,
                  borderRadius: BorderRadius.circular(FraternusRadii.pill),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
