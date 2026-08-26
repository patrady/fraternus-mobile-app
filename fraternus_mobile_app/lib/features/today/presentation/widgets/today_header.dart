import 'package:flutter/widgets.dart';

import '../../../../design_system/design_system.dart';

const _weekdayNames = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// Date + personalized greeting + profile icon button — only appears on
/// the Today tab root (other tab roots just show a bare uppercase
/// [Heading], per `07-profile.png`/`04-events-list.png`), so this stays
/// local to the Today feature rather than living in the design system.
///
/// The greeting ("Good morning, John") is sentence-case terracotta text
/// that doesn't fit [Subheading] (always uppercase) or [Heading] (no
/// custom-color param) — hence the raw [Text] here.
class TodayHeader extends StatelessWidget {
  const TodayHeader({
    super.key,
    required this.date,
    required this.greetingName,
    this.onProfileTap,
  });

  final DateTime date;
  final String greetingName;
  final VoidCallback? onProfileTap;

  String get _weekDayLabel {
    final weekday = _weekdayNames[date.weekday - 1];

    return weekday.toUpperCase();
  }

  String get _monthLabel {
    final month = _monthNames[date.month - 1];

    return month.toUpperCase();
  }

  String get _greeting {
    final hour = date.hour;

    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';

    return 'Good evening';
  }

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
              Heading(_weekDayLabel, level: HeadingLevel.h2),
              Heading(_monthLabel, level: HeadingLevel.h3),
              Text(
                '$_greeting, $greetingName',
                style: FraternusTypography.h4(
                  color: FraternusColors.accentPrimary,
                ),
              ),
            ],
          ),
        ),
        PressableBuilder(
          onTap: onProfileTap,
          semanticLabel: 'Profile',
          builder: (context, isPressed) {
            return Opacity(
              opacity: isPressed ? 0.75 : 1,
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: FraternusIcon(name: 'circle-user', size: 26),
              ),
            );
          },
        ),
      ],
    );
  }
}
