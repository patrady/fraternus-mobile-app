import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/design_system.dart';

/// A tappable box that looks like [FormTextField] but opens the shared
/// `showFraternusDatePicker` instead of accepting typed input. Feature-local
/// (only used by Add/Edit Child) rather than design-system-promoted.
class BirthdayField extends StatelessWidget {
  const BirthdayField({super.key, required this.date, required this.onTap});

  final DateTime? date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PressableBuilder(
      onTap: onTap,
      semanticLabel: 'Birthday',
      builder: (context, isPressed) {
        return Opacity(
          opacity: isPressed ? 0.85 : 1,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: FraternusColors.white,
              border: Border.all(color: FraternusColors.borderSubtle),
              borderRadius: BorderRadius.circular(FraternusRadii.sm),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date == null ? 'mm/dd/yyyy' : DateFormat('MM/dd/yyyy').format(date!),
                    style: FraternusTypography.body(
                      color: date == null ? FraternusColors.textOnLightMuted : FraternusColors.ink,
                    ).copyWith(fontSize: 15),
                  ),
                ),
                const FraternusIcon(name: 'calendar', size: 18),
              ],
            ),
          ),
        );
      },
    );
  }
}
