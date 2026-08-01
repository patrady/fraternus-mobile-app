import 'package:flutter/widgets.dart';

import '../icons/fraternus_icon.dart';
import '../internal/pressable_builder.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_typography.dart';

/// Top bar on every stacked screen — back chevron + uppercase title.
/// Ports components-source.jsx `ScreenHeader`.
class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
      child: Row(
        children: [
          PressableBuilder(
            onTap: onBack,
            semanticLabel: 'Back',
            builder: (context, isPressed) {
              return Opacity(
                opacity: isPressed ? 0.75 : 1,
                child: const SizedBox(
                  height: 44,
                  width: 32,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FraternusIcon(name: 'chevron-left', size: 22),
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          Text(
            title.toUpperCase(),
            style: FraternusTypography.h3(color: FraternusColors.forestGreen).copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }
}
