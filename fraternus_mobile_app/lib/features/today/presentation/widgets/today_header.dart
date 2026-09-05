import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../app/clock_provider.dart';
import '../../../../app/debug_unlock_provider.dart';
import '../../../../design_system/design_system.dart';
import '../../../../shared/formatting/ordinal_date_formatting.dart';

final _weekday = DateFormat('EEEE');
final _month = DateFormat('MMMM');

const _unlockTapCount = 10;
const _unlockTapWindow = Duration(seconds: 10);

/// Date + personalized greeting + profile icon button — only appears on
/// the Today tab root (other tab roots just show a bare uppercase
/// [Heading], per `07-profile.png`/`04-events-list.png`), so this stays
/// local to the Today feature rather than living in the design system.
///
/// The greeting ("Good morning, John") is sentence-case terracotta text
/// that doesn't fit [Subheading] (always uppercase) or [Heading] (no
/// custom-color param) — hence the raw [Text] here.
///
/// The weekday label doubles as the Debug tab's hidden unlock control (see
/// debug_unlock_provider.dart) — [_unlockTapCount] taps within
/// [_unlockTapWindow] toggles it, in either direction, same as tapping a
/// version number to reveal a hidden about screen. Debug-build-only: the
/// tap handler is a no-op outside kDebugMode, so this never does anything
/// in a release build even before the tab itself is compiled out.
class TodayHeader extends ConsumerStatefulWidget {
  const TodayHeader({
    super.key,
    required this.date,
    this.onProfileTap,
  });

  final DateTime date;
  final VoidCallback? onProfileTap;

  @override
  ConsumerState<TodayHeader> createState() => _TodayHeaderState();
}

class _TodayHeaderState extends ConsumerState<TodayHeader> {
  // Real wall-clock timestamps of recent taps — this gesture measures
  // actual elapsed time between taps, so it deliberately ignores the
  // Debug tab's own fake "now" (nowProvider) rather than using it.
  final List<DateTime> _recentTaps = [];

  void _handleWeekdayTap() {
    if (!kDebugMode) return;
    final now = DateTime.now();
    _recentTaps.add(now);
    _recentTaps.removeWhere((tap) => now.difference(tap) > _unlockTapWindow);
    if (_recentTaps.length >= _unlockTapCount) {
      _recentTaps.clear();
      ref.read(debugMenuUnlockedProvider.notifier).toggle();
    }
  }

  String get _weekDayLabel => _weekday.format(widget.date).toUpperCase();

  String get _monthDayLabel =>
      '${_month.format(widget.date).toUpperCase()} ${widget.date.day}${ordinalSuffix(widget.date.day).toUpperCase()}';

  String _greetingFor(int hour) {
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';

    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    // `date` is the dashboard's date-only "today" value (truncated to
    // midnight for use as a provider cache key upstream), so it has no
    // real time-of-day — read the hour from the shared clock (real wall
    // clock, unless the Debug tab has overridden it) instead.
    final greeting = _greetingFor(ref.watch(nowProvider).hour);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _handleWeekdayTap,
                child: Heading(_weekDayLabel, level: HeadingLevel.h2),
              ),
              Heading(_monthDayLabel, level: HeadingLevel.h3),
              const SizedBox(height: 4),
              Text(
                '$greeting!',
                style: FraternusTypography.h4(
                  color: FraternusColors.accentPrimary,
                ),
              ),
            ],
          ),
        ),
        PressableBuilder(
          onTap: widget.onProfileTap,
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
