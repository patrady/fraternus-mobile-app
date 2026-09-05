import 'package:flutter/widgets.dart';

import '../icons/fraternus_icon.dart';
import '../internal/pressable_builder.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';
import '../tokens/fraternus_typography.dart';

/// Generic row shape underlying ProfileRow, TodoRow, and the "Others
/// Attending" rows — leading icon/avatar, label + optional sublabel,
/// trailing chevron or control. Ports components-source.jsx `ListRow`.
class ListRow extends StatelessWidget {
  const ListRow({
    super.key,
    this.leading,
    required this.label,
    this.sublabel,
    this.trailing,
    this.chevron = true,
    this.bordered = true,
    this.onPressed,
  });

  final Widget? leading;
  final String label;
  final String? sublabel;
  final Widget? trailing;
  final bool chevron;
  final bool bordered;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return PressableBuilder(
      onTap: onPressed,
      semanticLabel: label,
      builder: (context, isPressed) {
        return Opacity(
          opacity: isPressed ? 0.9 : 1,
          child: Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: bordered ? 12 : 0),
            padding: bordered
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
                : const EdgeInsets.symmetric(vertical: 11),
            constraints: const BoxConstraints(
              minHeight: FraternusSpacing.tapTargetMin,
            ),
            decoration: bordered
                ? BoxDecoration(
                    color: FraternusColors.white,
                    border: Border.all(color: FraternusColors.borderSubtle),
                    borderRadius: BorderRadius.circular(FraternusRadii.lg),
                  )
                : null,
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 12)],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: FraternusTypography.body(
                          color: FraternusColors.ink,
                        ).copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                      if (sublabel != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(
                            sublabel!,
                            style: FraternusTypography.small(
                              color: FraternusColors.textOnLightMuted,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (chevron)
                  const FraternusIcon(name: 'chevron-right', size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}
