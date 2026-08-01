import 'package:flutter/widgets.dart';

import '../avatar/avatar.dart';
import '../tags/tag.dart';
import '../icons/fraternus_icon.dart';
import '../internal/pressable_builder.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';
import '../tokens/fraternus_typography.dart';

/// Summary/list row for a person — added children in the wizard, "You" /
/// "Your Children" in the final summary. Ports components-source.jsx
/// `InfoCard`.
class InfoCard extends StatelessWidget {
  const InfoCard({
    super.key,
    this.initials,
    required this.title,
    required this.subtitle,
    this.badge,
    this.onRemove,
  });

  final String? initials;
  final String title;
  final String subtitle;
  final String? badge;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: FraternusColors.white,
        border: Border.all(color: FraternusColors.borderSubtle),
        borderRadius: BorderRadius.circular(FraternusRadii.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (initials != null) ...[
            Avatar(initials: initials!),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: FraternusTypography.body(color: FraternusColors.ink).copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: FraternusTypography.small(color: FraternusColors.textOnLightMuted),
                ),
                if (badge != null) ...[
                  const SizedBox(height: 8),
                  Tag(label: badge!, color: TagColor.secondary),
                ],
              ],
            ),
          ),
          if (onRemove != null)
            PressableBuilder(
              onTap: onRemove,
              semanticLabel: 'Remove',
              builder: (context, isPressed) {
                return Opacity(
                  opacity: isPressed ? 0.75 : 1,
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: FraternusIcon(name: 'x', size: 18),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
