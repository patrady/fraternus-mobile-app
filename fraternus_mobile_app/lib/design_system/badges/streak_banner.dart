import 'package:flutter/widgets.dart';

import '../icons/fraternus_icon.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';
import '../tokens/fraternus_typography.dart';

/// "N Day Streak" — dark rounded bar with flame icon, sits above the daily
/// reading content on the Guide tab. Ports components-source.jsx
/// `StreakBanner`.
class StreakBanner extends StatelessWidget {
  const StreakBanner({
    super.key,
    required this.count,
    this.label = 'Day Streak',
  });

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: FraternusColors.surfaceDark,
        borderRadius: BorderRadius.circular(FraternusRadii.md),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const FraternusIcon(
            name: 'flame',
            size: 16,
            tone: FraternusIconTone.terracotta,
          ),
          const SizedBox(width: 8),
          Text(
            '$count ${label.toUpperCase()}',
            style: FraternusTypography.button(
              fontSize: 13,
              color: FraternusColors.white,
            ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 13 * 0.04),
          ),
        ],
      ),
    );
  }
}
