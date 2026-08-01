import 'package:flutter/widgets.dart';

import '../icons/fraternus_icon.dart';
import '../internal/pressable_builder.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';
import '../tokens/fraternus_typography.dart';

/// Dark celebratory/result card — "Challenge Complete!", "Your
/// Temperament". Ports components-source.jsx `DarkFeatureCard`.
class DarkFeatureCard extends StatelessWidget {
  const DarkFeatureCard({
    super.key,
    this.icon,
    this.eyebrow,
    this.value,
    this.body,
    this.ctaLabel,
    this.onCta,
  });

  final String? icon;
  final String? eyebrow;
  final String? value;
  final String? body;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 22),
      decoration: BoxDecoration(
        color: FraternusColors.surfaceDark,
        borderRadius: BorderRadius.circular(FraternusRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (icon != null) ...[
            FraternusIcon(name: icon!, size: 32, tone: FraternusIconTone.white),
            const SizedBox(height: 14),
          ],
          if (eyebrow != null) ...[
            Text(
              eyebrow!.toUpperCase(),
              textAlign: TextAlign.center,
              style: FraternusTypography.eyebrow(color: FraternusColors.accentPrimary),
            ),
            const SizedBox(height: 6),
          ],
          if (value != null) ...[
            Text(
              value!.toUpperCase(),
              textAlign: TextAlign.center,
              style: FraternusTypography.button(fontSize: 22, color: FraternusColors.white)
                  .copyWith(fontWeight: FontWeight.w700, letterSpacing: 0),
            ),
            const SizedBox(height: 18),
          ],
          if (body != null) ...[
            Text(
              body!,
              textAlign: TextAlign.center,
              style: FraternusTypography.body(color: FraternusColors.textOnDarkMuted),
            ),
            const SizedBox(height: 16),
          ],
          if (ctaLabel != null)
            PressableBuilder(
              onTap: onCta,
              semanticLabel: ctaLabel,
              builder: (context, isPressed) {
                return Opacity(
                  opacity: isPressed ? 0.75 : 1,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                    constraints: const BoxConstraints(minHeight: 44),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0x66FFFFFF)),
                      borderRadius: BorderRadius.circular(FraternusRadii.sm),
                    ),
                    child: Text(
                      ctaLabel!.toUpperCase(),
                      style: FraternusTypography.button(fontSize: 12, color: FraternusColors.white)
                          .copyWith(letterSpacing: 12 * 0.03),
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
