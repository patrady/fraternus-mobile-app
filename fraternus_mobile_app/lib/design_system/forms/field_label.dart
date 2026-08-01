import 'package:flutter/widgets.dart';

import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_typography.dart';

/// Label shown above every form input (Email, Password, First Name, etc).
/// Ports components-source.jsx `FieldLabel`.
class FieldLabel extends StatelessWidget {
  const FieldLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label.toUpperCase(),
        style: FraternusTypography.button(
          fontSize: 12,
          color: FraternusColors.textOnLightMuted,
        ).copyWith(fontWeight: FontWeight.w700, letterSpacing: 12 * 0.05),
      ),
    );
  }
}
