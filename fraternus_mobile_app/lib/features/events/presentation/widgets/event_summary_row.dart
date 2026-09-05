import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fraternus_mobile_app/shared/formatting/date_time_utils.dart';

import '../../../../app/clock_provider.dart';
import '../../../../design_system/design_system.dart';
import '../../../../shared/formatting/event_date_formatting.dart';
import '../../models/event.dart';

/// One event's card in the Events list — title (struck through when
/// cancelled), a clock/date line, a location line, and a trailing status
/// (a countdown [Tag] when starting soon, "CANCELLED" text, or nothing).
/// Feature-local rather than a design-system component: nothing in
/// components-source.jsx modeled this shape, and it's only used here.
class EventSummaryRow extends ConsumerWidget {
  const EventSummaryRow({
    super.key,
    required this.event,
    required this.onPressed,
  });

  final Event event;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cancelled = event.isCancelled;
    final startingSoonLabel = cancelled
        ? null
        : formatStartingSoonLabel(ref.watch(nowProvider), event.startAt);

    return PressableBuilder(
      onTap: onPressed,
      semanticLabel: event.title,
      builder: (context, isPressed) {
        return Opacity(
          opacity: isPressed ? 0.9 : 1,
          child: Box(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FraternusIcon(
                            name: event.type.iconName,
                            size: 16,
                            opacity: cancelled ? 0.4 : 0.6,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.title,
                              style:
                                  FraternusTypography.h4(
                                    color: cancelled
                                        ? FraternusColors.textOnLightMuted
                                        : FraternusColors.ink,
                                  ).copyWith(
                                    decoration: cancelled
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (isSameDay(
                        event.startAt.toLocal(),
                        event.endAt.toLocal(),
                      ))
                        _MetaLine(
                          icon: 'clock',
                          label: formatEventDateRange(
                            event.startAt.toLocal(),
                            event.endAt.toLocal(),
                          ),
                        )
                      else ...[
                        _MetaLine(
                          icon: 'clock',
                          label: formatDayTimeLabel(event.startAt.toLocal()),
                        ),
                        Row(
                          children: [
                            const SizedBox(width: 20),
                            Text(
                              "to ",
                              style: FraternusTypography.small(
                                color: FraternusColors.textOnLightMuted,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                formatDayTimeLabel(event.endAt.toLocal()),
                                style: FraternusTypography.small(
                                  color: FraternusColors.textOnLightMuted,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],

                      if (event.location case final location?) ...[
                        const SizedBox(height: 4),
                        _MetaLine(icon: 'map-pin', label: location.name),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (cancelled)
                      Text(
                        'CANCELLED',
                        style: FraternusTypography.eyebrow(
                          color: FraternusColors.error,
                        ),
                      )
                    else if (startingSoonLabel != null)
                      Tag(label: startingSoonLabel, size: TagSize.small),
                    const SizedBox(height: 20),
                    const FraternusIcon(
                      name: 'chevron-right',
                      size: 18,
                      opacity: 0.5,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.label});

  final String icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FraternusIcon(name: icon, size: 14, opacity: 0.55),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: FraternusTypography.small(
              color: FraternusColors.textOnLightMuted,
            ),
          ),
        ),
      ],
    );
  }
}
