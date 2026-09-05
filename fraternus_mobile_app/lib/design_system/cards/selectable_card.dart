import 'package:flutter/widgets.dart';

import '../icons/fraternus_icon.dart';
import '../internal/pressable_builder.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';
import '../tokens/fraternus_typography.dart';

/// Role-selection card (icon chip + title + description, selected state).
/// Ports components-source.jsx `SelectableCard`.
class SelectableCard extends StatelessWidget {
  const SelectableCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.selected = false,
    this.onPressed,
    this.muted = false,
  });

  final String icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback? onPressed;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: PressableBuilder(
        onTap: onPressed,
        semanticLabel: title,
        builder: (context, isPressed) {
          return Opacity(
            opacity: isPressed ? 0.9 : 1,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: muted
                  ? null
                  : BoxDecoration(
                      color: FraternusColors.white,
                      border: Border.all(
                        color: selected
                            ? FraternusColors.accentPrimary
                            : FraternusColors.borderSubtle,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(FraternusRadii.lg),
                    ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? FraternusColors.accentPrimary
                          : FraternusColors.surfaceCardDim,
                    ),
                    alignment: Alignment.center,
                    child: FraternusIcon(
                      name: icon,
                      size: 22,
                      tone: selected
                          ? FraternusIconTone.white
                          : FraternusIconTone.ink,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title.toUpperCase(),
                          style: FraternusTypography.h4(
                            color: FraternusColors.forestGreen,
                          ).copyWith(fontWeight: FontWeight.w700, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: FraternusTypography.small(
                            color: FraternusColors.textOnLightMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
