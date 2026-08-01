import 'package:flutter/widgets.dart';

import '../internal/pressable_builder.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';
import '../tokens/fraternus_typography.dart';

enum RsvpStatus { yes, no }

/// Two-option pill toggle for event RSVPs (Going / Can't), tri-state
/// color. Ports components-source.jsx `RsvpToggle`.
class RsvpToggle extends StatelessWidget {
  const RsvpToggle({super.key, this.status, required this.onChanged});

  final RsvpStatus? status;
  final ValueChanged<RsvpStatus> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _option(RsvpStatus.yes, 'Going', FraternusColors.success),
        const SizedBox(width: 8),
        _option(RsvpStatus.no, "Can't", FraternusColors.error),
      ],
    );
  }

  Widget _option(RsvpStatus value, String label, Color selectedColor) {
    final selected = status == value;
    return PressableBuilder(
      onTap: () => onChanged(value),
      semanticLabel: label,
      builder: (context, isPressed) {
        return Opacity(
          opacity: isPressed ? 0.85 : 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            constraints: const BoxConstraints(minHeight: 36),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? selectedColor : FraternusColors.white,
              border: selected ? null : Border.all(color: FraternusColors.borderSubtle),
              borderRadius: BorderRadius.circular(FraternusRadii.sm),
            ),
            child: Text(
              label.toUpperCase(),
              style: FraternusTypography.button(
                fontSize: 12,
                color: selected ? FraternusColors.white : FraternusColors.textOnLightMuted,
              ).copyWith(letterSpacing: 12 * 0.03),
            ),
          ),
        );
      },
    );
  }
}
