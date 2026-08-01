import 'package:flutter/widgets.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'package:fraternus_mobile_app/design_system/icons/fraternus_icons.dart';
import 'package:fraternus_mobile_app/design_system/tokens/fraternus_colors.dart';
import 'package:fraternus_mobile_app/design_system/buttons/button.dart';

/// Interactive use case exposing every Button knob — size, variant, color,
/// full width, disabled, icon and icon position. To try a new icon, add it
/// to [FraternusIcons.byName] first; it then shows up in the "Icon" dropdown
/// below and everywhere else icons are referenced by name.
@widgetbook.UseCase(name: 'Playground', type: Button)
Widget playgroundUseCase(BuildContext context) {
  return Center(
    child: Button(
      label: context.knobs.string(label: 'Label', initialValue: 'Continue'),
      size: context.knobs.object.dropdown<ButtonSize>(
        label: 'Size',
        options: ButtonSize.values,
        initialOption: ButtonSize.medium,
        labelBuilder: (value) => value.name,
      ),
      variant: context.knobs.object.dropdown<ButtonVariant>(
        label: 'Variant',
        options: ButtonVariant.values,
        initialOption: ButtonVariant.primary,
        labelBuilder: (value) => value.name,
      ),
      color: context.knobs.object.dropdown<ButtonColor>(
        label: 'Color',
        options: ButtonColor.values,
        initialOption: ButtonColor.primary,
        labelBuilder: (value) => value.name,
      ),
      fullWidth: context.knobs.boolean(label: 'Full width', initialValue: false),
      disabled: context.knobs.boolean(label: 'Disabled', initialValue: false),
      onDark: context.knobs.boolean(label: 'On dark', initialValue: false),
      icon: context.knobs.objectOrNull.dropdown<String?>(
        label: 'Icon',
        options: [null, ...FraternusIcons.byName.keys],
        initialOption: null,
        labelBuilder: (value) => value ?? 'None',
      ),
      iconPosition: context.knobs.object.dropdown<ButtonIconPosition>(
        label: 'Icon position',
        options: ButtonIconPosition.values,
        initialOption: ButtonIconPosition.left,
        labelBuilder: (value) => value.name,
      ),
      onPressed: () {},
    ),
  );
}

@widgetbook.UseCase(name: 'Sizes', type: Button)
Widget sizesUseCase(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Button(label: 'Small', size: ButtonSize.small, onPressed: () {}),
        const SizedBox(height: 12),
        Button(label: 'Medium (default)', onPressed: () {}),
        const SizedBox(height: 12),
        Button(label: 'Large', size: ButtonSize.large, onPressed: () {}),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Variant x color', type: Button)
Widget variantColorUseCase(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final variant in ButtonVariant.values) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final color in ButtonColor.values) ...[
                Button(label: color.name, variant: variant, color: color, onPressed: () {}),
                const SizedBox(width: 12),
              ],
            ],
          ),
          const SizedBox(height: 12),
        ],
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'With icon', type: Button)
Widget withIconUseCase(BuildContext context) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Button(label: "Let's Get Started", icon: 'chevron-right', onPressed: () {}),
        const SizedBox(height: 12),
        Button(
          label: 'Add Child',
          variant: ButtonVariant.ghost,
          icon: 'plus',
          iconPosition: ButtonIconPosition.left,
          onPressed: () {},
        ),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Full width', type: Button)
Widget fullWidthUseCase(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        Button(label: 'Continue', fullWidth: true, onPressed: () {}),
        const SizedBox(height: 12),
        Button(label: 'Cancel', variant: ButtonVariant.ghost, fullWidth: true, onPressed: () {}),
      ],
    ),
  );
}

@widgetbook.UseCase(name: 'Disabled', type: Button)
Widget disabledUseCase(BuildContext context) {
  return const Center(child: Button(label: 'Continue', disabled: true));
}

/// Underlined buttons render as plain text with no fill of their own, so —
/// unlike the filled/ghost variants — they read as invisible floating text
/// against Widgetbook's canvas (especially in dark theme, since their text
/// colors assume a light surface). Every use case here is framed in an
/// explicit light card so the button is always legible regardless of the
/// surrounding canvas theme.
@widgetbook.UseCase(name: 'Underlined', type: Button)
Widget underlinedUseCase(BuildContext context) {
  return Center(
    child: Container(
      padding: const EdgeInsets.all(20),
      color: FraternusColors.surfaceCardLight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Button(label: 'Forgot Password?', variant: ButtonVariant.underlined, onPressed: () {}),
          const SizedBox(height: 8),
          Button(
            label: 'Resend Code',
            variant: ButtonVariant.underlined,
            color: ButtonColor.secondary,
            onPressed: () {},
          ),
          const SizedBox(height: 8),
          Button(
            label: 'Remove Child',
            variant: ButtonVariant.underlined,
            color: ButtonColor.danger,
            onPressed: () {},
          ),
        ],
      ),
    ),
  );
}

@widgetbook.UseCase(name: 'Underlined — on dark', type: Button)
Widget underlinedOnDarkUseCase(BuildContext context) {
  return Center(
    child: Container(
      padding: const EdgeInsets.all(20),
      color: FraternusColors.surfaceDark,
      child: Button(
        label: 'Skip for now',
        variant: ButtonVariant.underlined,
        onDark: true,
        onPressed: () {},
      ),
    ),
  );
}
