import 'package:flutter/widgets.dart';

import '../icons/fraternus_icon.dart';
import '../internal/pressable_builder.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';
import '../tokens/fraternus_typography.dart';

/// Dark, left-aligned, tappable summary row — muted-white eyebrow stacked
/// above a bold white headline, with a trailing chevron. Used for entry
/// points into a larger piece of content (e.g. "This Week's Focus" ->
/// "Humility" on the Today screen). Distinct from [DarkFeatureCard], which
/// is a centered icon/eyebrow/value/body/CTA column, not a tappable link row.
class DarkSummaryCard extends StatelessWidget {
  const DarkSummaryCard({super.key, required this.eyebrow, required this.title, this.onPressed});

  final String eyebrow;
  final String title;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PressableBuilder(
      onTap: onPressed,
      semanticLabel: title,
      builder: (context, isPressed) {
        return Opacity(
          opacity: isPressed ? 0.9 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            decoration: BoxDecoration(
              color: FraternusColors.surfaceDark,
              borderRadius: BorderRadius.circular(FraternusRadii.lg),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        eyebrow.toUpperCase(),
                        style: FraternusTypography.eyebrow(color: FraternusColors.textOnDarkMuted),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title.toUpperCase(),
                        style: FraternusTypography.button(fontSize: 22, color: FraternusColors.white)
                            .copyWith(fontWeight: FontWeight.w700, letterSpacing: 0),
                      ),
                    ],
                  ),
                ),
                const FraternusIcon(name: 'chevron-right', size: 20, tone: FraternusIconTone.white),
              ],
            ),
          ),
        );
      },
    );
  }
}
