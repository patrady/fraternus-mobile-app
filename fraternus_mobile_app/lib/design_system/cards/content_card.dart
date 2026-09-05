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

  /// True when there's no eyebrow/title header row to anchor the like
  /// button against — the quote-card shape (subtitle is the only text
  /// above [child]). In that case the like button flexes inline with the
  /// subtitle itself instead of sitting above it in its own row, which
  /// would otherwise leave an empty-looking gap the height of the icon.
  bool get _headerless => eyebrow == null && title == null && subtitle != null;

  Widget _likeButton(BuildContext context) {
    return PressableBuilder(
      onTap: onLike,
      semanticLabel: 'Like',
      builder: (context, isPressed) {
        return Opacity(
          opacity: isPressed ? 0.75 : 1,
          child: FraternusIcon(
            name: liked ? 'heart-filled' : 'heart',
            size: 19,
            tone: liked ? FraternusIconTone.error : FraternusIconTone.ink,
          ),
        );
      },
    );
  }

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
          if (_headerless)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    subtitle!,
                    style: FraternusTypography.body(
                      color: FraternusColors.textOnLightMuted,
                    ).copyWith(fontSize: 15, fontStyle: FontStyle.italic),
                  ),
                ),
                if (onLike != null) ...[
                  const SizedBox(width: 12),
                  _likeButton(context),
                ],
              ],
            )
          else ...[
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
                          style: FraternusTypography.eyebrow(
                            color: FraternusColors.accentPrimary,
                          ),
                        ),
                      if (title != null)
                        Text(
                          title!,
                          style: FraternusTypography.h4(
                            color: FraternusColors.forestGreen,
                          ).copyWith(fontSize: 18),
                        ),
                    ],
                  ),
                ),
                if (onLike != null) _likeButton(context),
              ],
            ),
            SizedBox(height: subtitle != null ? 6 : 10),
            if (subtitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  subtitle!,
                  style: FraternusTypography.body(
                    color: FraternusColors.textOnLightMuted,
                  ).copyWith(fontSize: 13, fontStyle: FontStyle.italic),
                ),
              ),
          ],
          if (_headerless) const SizedBox(height: 12),
          ?child,
        ],
      ),
    );
  }
}
