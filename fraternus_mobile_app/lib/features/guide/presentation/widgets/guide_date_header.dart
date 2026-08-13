import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/design_system.dart';

final _dateFormat = DateFormat('MMMM d');

/// Date + virtue name + calendar-picker trigger, mirroring TodayHeader's
/// layout/icon-button conventions but with a date-picker affordance
/// instead of a profile link, and a virtue name instead of a greeting.
///
/// [virtue] is nullable so the header (and its calendar picker, the only
/// way back to a valid date) can still render on dates with no reading —
/// see GuideScreen's no-reading fallback.
class GuideDateHeader extends StatelessWidget {
  const GuideDateHeader({super.key, required this.date, this.virtue, this.onCalendarTap});

  final DateTime date;
  final String? virtue;
  final VoidCallback? onCalendarTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Heading(_dateFormat.format(date).toUpperCase(), level: HeadingLevel.h2),
              if (virtue != null) ...[
                const SizedBox(height: 4),
                Heading(virtue!.toUpperCase(), level: HeadingLevel.h4),
              ],
            ],
          ),
        ),
        PressableBuilder(
          onTap: onCalendarTap,
          semanticLabel: 'Pick a date',
          builder: (context, isPressed) {
            return Opacity(
              opacity: isPressed ? 0.75 : 1,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: FraternusColors.borderSubtle),
                ),
                alignment: Alignment.center,
                child: const FraternusIcon(name: 'calendar', size: 18),
              ),
            );
          },
        ),
      ],
    );
  }
}
