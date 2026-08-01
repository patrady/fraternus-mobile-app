import 'package:flutter/widgets.dart';

import '../icons/fraternus_icons.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';
import '../tokens/fraternus_typography.dart';

enum TagColor { primary, secondary }

enum TagSize { small, medium, large }

enum TagIconPosition { left, right }

/// Small filled label for role/category/status — "Captain", "Entire
/// Chapter", "New". Ports components-source.jsx `Pill`.
class Tag extends StatelessWidget {
  const Tag({
    super.key,
    required this.label,
    this.color = TagColor.primary,
    this.size = TagSize.medium,
    this.icon,
    this.iconPosition = TagIconPosition.left,
  });

  final String label;
  final TagColor color;
  final TagSize size;

  /// Name of an icon registered in [FraternusIcons.byName].
  final String? icon;
  final TagIconPosition iconPosition;

  Color get _background => switch (color) {
    TagColor.primary => FraternusColors.forestGreen,
    TagColor.secondary => FraternusColors.accentPrimary,
  };

  double get _fontSize => switch (size) {
    TagSize.small => 10.0,
    TagSize.medium => 11.0,
    TagSize.large => 13.0,
  };

  double get _iconSize => switch (size) {
    TagSize.small => 10.0,
    TagSize.medium => 12.0,
    TagSize.large => 14.0,
  };

  EdgeInsets get _padding => switch (size) {
    TagSize.small => const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    TagSize.medium => const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    TagSize.large => const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  };

  @override
  Widget build(BuildContext context) {
    final iconWidget = icon == null
        ? null
        : Icon(FraternusIcons.resolve(icon!), size: _iconSize, color: FraternusColors.white);

    return Container(
      padding: _padding,
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(FraternusRadii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (iconWidget != null && iconPosition == TagIconPosition.left) ...[
            iconWidget,
            const SizedBox(width: 4),
          ],
          Text(
            label.toUpperCase(),
            style: FraternusTypography.button(
              fontSize: _fontSize,
              color: FraternusColors.white,
            ).copyWith(fontWeight: FontWeight.w700, letterSpacing: _fontSize * 0.04),
          ),
          if (iconWidget != null && iconPosition == TagIconPosition.right) ...[
            const SizedBox(width: 4),
            iconWidget,
          ],
        ],
      ),
    );
  }
}
