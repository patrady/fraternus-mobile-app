import 'package:flutter/material.dart';

import '../buttons/button.dart';
import '../buttons/button_group.dart';
import '../icons/fraternus_icon.dart';
import '../internal/pressable_builder.dart';
import '../tokens/fraternus_colors.dart';
import '../tokens/fraternus_spacing.dart';
import '../tokens/fraternus_typography.dart';
import '../typography/heading.dart';

/// First modal in the codebase — a themed confirmation dialog (Logout,
/// destructive confirmations, etc). Follows the same "wrap the stock
/// Flutter overlay API, then theme it" shape as
/// `showFraternusDatePicker`. Returns true only if the confirm button was
/// tapped; false on any dismissal (Cancel, the close X, or tapping outside).
Future<bool> showFraternusConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Confirm',
  String cancelLabel = 'Cancel',
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierColor: const Color(0x66000000),
    builder: (context) {
      return Dialog(
        backgroundColor: FraternusColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(FraternusRadii.lg)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: Heading(title, level: HeadingLevel.h3)),
                  PressableBuilder(
                    onTap: () => Navigator.of(context).pop(false),
                    semanticLabel: 'Close',
                    builder: (context, isPressed) {
                      return Opacity(
                        opacity: isPressed ? 0.75 : 1,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: FraternusColors.surfaceCardDim,
                          ),
                          alignment: Alignment.center,
                          child: const FraternusIcon(name: 'x', size: 14),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                message,
                style: FraternusTypography.body(
                  color: FraternusColors.textOnLightMuted,
                ),
              ),
              const SizedBox(height: 20),
              ButtonGroup(
                children: [
                  Button(
                    label: cancelLabel,
                    variant: ButtonVariant.ghost,
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  Button(
                    label: confirmLabel,
                    color: ButtonColor.danger,
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return result ?? false;
}
