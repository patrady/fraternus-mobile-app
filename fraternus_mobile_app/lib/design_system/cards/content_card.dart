import 'package:flutter/widgets.dart';

import '../icons/fraternus_icon.dart';
import '../internal/pressable_builder.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';
import '../tokens/fraternus_typography.dart';

/// General-purpose bordered card for eyebrow+title+body content — powers
/// SectionCard, QuoteCard, and EventCard's text pattern. Ports
/// components-source.jsx `ContentCard`.
class ContentCard extends StatelessWidget {
  const ContentCard({
    super.key,
    this.eyebrow,
    this.title,
    this.subtitle,
    this.child,
    this.onLike,
    this.liked = false,
  });

  final String? eyebrow;
  final String? title;
  final String? subtitle;
  final Widget? child;
  final VoidCallback? onLike;
  final bool liked;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
      decoration: BoxDecoration(
        color: FraternusColors.white,
        border: Border.all(color: FraternusColors.borderSubtle),
        borderRadius: BorderRadius.circular(FraternusRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (eyebrow != null)
                      Text(
                        eyebrow!.toUpperCase(),
                        style: FraternusTypography.eyebrow(color: FraternusColors.accentPrimary),
                      ),
                    if (title != null)
                      Text(
                        title!,
                        style: FraternusTypography.h4(color: FraternusColors.forestGreen).copyWith(fontSize: 18),
                      ),
                  ],
                ),
              ),
              if (onLike != null)
                PressableBuilder(
                  onTap: onLike,
                  semanticLabel: 'Like',
                  builder: (context, isPressed) {
                    return Opacity(
                      opacity: isPressed ? 0.75 : 1,
                      child: FraternusIcon(
                        name: 'heart',
                        size: 19,
                        tone: liked ? FraternusIconTone.error : FraternusIconTone.ink,
                      ),
                    );
                  },
                ),
            ],
          ),
          SizedBox(height: subtitle != null ? 6 : 10),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                subtitle!,
                style: FraternusTypography.body(color: FraternusColors.textOnLightMuted)
                    .copyWith(fontSize: 13, fontStyle: FontStyle.italic),
              ),
            ),
          ?child,
        ],
      ),
    );
  }
}
