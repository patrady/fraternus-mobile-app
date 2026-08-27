import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../../design_system/design_system.dart';
import '../../../../shared/formatting/ordinal_date_formatting.dart';

final _weekday = DateFormat('EEEE');
final _month = DateFormat('MMMM');

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

  String get _weekDayLabel => _weekday.format(date).toUpperCase();

  String get _monthDayLabel => '${_month.format(date).toUpperCase()} ${date.day}${ordinalSuffix(date.day).toUpperCase()}';

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
              Heading(_monthDayLabel, level: HeadingLevel.h3),
              const SizedBox(height: 4),
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
