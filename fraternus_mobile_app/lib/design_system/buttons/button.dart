import 'package:flutter/widgets.dart';

import '../icons/fraternus_icons.dart';
import '../internal/pressable_builder.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';
import '../tokens/fraternus_typography.dart';

enum ButtonSize { small, medium, large }

enum ButtonVariant { primary, ghost, underlined }

enum ButtonColor { primary, secondary, danger }

enum ButtonIconPosition { left, right }

/// Unified action button covering the filled ("primary"), outlined
/// ("ghost") and text-link ("underlined") looks used across the app.
/// Replaces the old PrimaryButton/SecondaryButton/DangerButton/LinkButton
/// quartet with one component driven by [variant] x [color].
///
/// Hugs its label by default at every size — pass [fullWidth] for the
/// full-bleed CTA look used in onboarding/forms.
class Button extends StatelessWidget {
  const Button({
    super.key,
    required this.label,
    this.onPressed,
    this.size = ButtonSize.medium,
    this.variant = ButtonVariant.primary,
    this.color = ButtonColor.primary,
    this.fullWidth = false,
    this.disabled = false,
    this.onDark = false,
    this.icon,
    this.iconPosition = ButtonIconPosition.left,
  });

  final String label;
  final VoidCallback? onPressed;
  final ButtonSize size;
  final ButtonVariant variant;
  final ButtonColor color;
  final bool fullWidth;
  final bool disabled;

  /// Set when placing a [ButtonVariant.ghost] or [ButtonVariant.underlined]
  /// button directly on a dark surface (e.g. [ButtonColor.primary]'s
  /// forest-green text is illegible there) — swaps text/border for a
  /// light-on-dark treatment. Filled ([ButtonVariant.primary]) buttons are
  /// already white-on-color and ignore this.
  final bool onDark;

  /// Name of an icon registered in [FraternusIcons.byName]. To use a new
  /// icon, add its Lucide codepoint to that map — it's then available here
  /// (and anywhere else that map is used) under the new name.
  final String? icon;
  final ButtonIconPosition iconPosition;

  double get _fontSize => switch (size) {
    ButtonSize.small => 13.0,
    ButtonSize.medium => 14.0,
    ButtonSize.large => 18.0,
  };

  double get _iconSize => switch (size) {
    ButtonSize.small => 14.0,
    ButtonSize.medium => 16.0,
    ButtonSize.large => 20.0,
  };

  EdgeInsets get _padding => switch (size) {
    ButtonSize.small => const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
    ButtonSize.medium => const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
    ButtonSize.large => const EdgeInsets.symmetric(horizontal: 38, vertical: 22),
  };

  Color get _fillColor => switch (color) {
    ButtonColor.primary => FraternusColors.accentPrimary,
    ButtonColor.secondary => FraternusColors.forestGreen,
    ButtonColor.danger => FraternusColors.error,
  };

  Color get _fillColorPressed => Color.lerp(_fillColor, const Color(0xFF000000), 0.16)!;

  Color get _textColor {
    if (variant == ButtonVariant.primary) return FraternusColors.white;
    if (onDark) return FraternusColors.textOnDark;
    return switch (color) {
      ButtonColor.primary => FraternusColors.forestGreen,
      ButtonColor.secondary => FraternusColors.textOnLightMuted,
      ButtonColor.danger => FraternusColors.error,
    };
  }

  TextStyle get _textStyle {
    final style = FraternusTypography.button(fontSize: _fontSize, color: _textColor);
    return variant == ButtonVariant.underlined
        ? style.copyWith(decoration: TextDecoration.underline, decorationColor: _textColor)
        : style;
  }

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: disabled ? 0.5 : 1,
      child: PressableBuilder(
        disabled: disabled,
        onTap: onPressed,
        semanticLabel: label,
        builder: (context, isPressed) => _buildContent(isPressed),
      ),
    );
  }

  Widget _buildContent(bool isPressed) {
    final iconWidget = icon == null
        ? null
        : Icon(FraternusIcons.resolve(icon!), size: _iconSize, color: _textColor);

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconWidget != null && iconPosition == ButtonIconPosition.left) ...[
          iconWidget,
          const SizedBox(width: 8),
        ],
        Text(label.toUpperCase(), style: _textStyle),
        if (iconWidget != null && iconPosition == ButtonIconPosition.right) ...[
          const SizedBox(width: 8),
          iconWidget,
        ],
      ],
    );

    final Widget child = switch (variant) {
      ButtonVariant.primary => Container(
        padding: _padding,
        constraints: const BoxConstraints(minHeight: FraternusSpacing.tapTargetMin),
        decoration: BoxDecoration(
          color: isPressed ? _fillColorPressed : _fillColor,
          borderRadius: BorderRadius.circular(FraternusRadii.sm),
        ),
        alignment: Alignment.center,
        child: content,
      ),
      ButtonVariant.ghost => Opacity(
        opacity: isPressed ? 0.75 : 1,
        child: Container(
          padding: _padding,
          constraints: const BoxConstraints(minHeight: FraternusSpacing.tapTargetMin),
          decoration: BoxDecoration(
            color: onDark ? null : FraternusColors.white,
            border: Border.all(
              color: onDark ? FraternusColors.borderOnDark : FraternusColors.borderSubtle,
            ),
            borderRadius: BorderRadius.circular(FraternusRadii.sm),
          ),
          alignment: Alignment.center,
          child: content,
        ),
      ),
      ButtonVariant.underlined => Opacity(
        opacity: isPressed ? 0.75 : 1,
        child: Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: content),
      ),
    };

    return fullWidth ? SizedBox(width: double.infinity, child: child) : child;
  }
}
