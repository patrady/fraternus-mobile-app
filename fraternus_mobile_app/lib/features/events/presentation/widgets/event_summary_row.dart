import 'package:flutter/widgets.dart';

import '../../../../design_system/design_system.dart';
import '../../../../shared/formatting/event_date_formatting.dart';
import '../../models/event.dart';

/// One event's card in the Events list — title (struck through when
/// cancelled), a clock/date line, a location line, and a trailing status
/// (a countdown [Tag] when starting soon, "CANCELLED" text, or nothing).
/// Feature-local rather than a design-system component: nothing in
/// components-source.jsx modeled this shape, and it's only used here.
class EventSummaryRow extends StatelessWidget {
  const EventSummaryRow({super.key, required this.event, required this.onPressed});

  final Event event;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final cancelled = event.isCancelled;
    final startingSoonLabel = cancelled ? null : formatStartingSoonLabel(DateTime.now(), event.startAt);

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
                      Text(
                        event.title,
                        style: FraternusTypography.h4(
                          color: cancelled ? FraternusColors.textOnLightMuted : FraternusColors.ink,
                        ).copyWith(decoration: cancelled ? TextDecoration.lineThrough : null),
                      ),
                      const SizedBox(height: 8),
                      _MetaLine(icon: 'clock', label: formatEventDateRange(event.startAt, event.endAt)),
                      if (event.location case final location?) ...[
                        const SizedBox(height: 4),
                        _MetaLine(icon: 'map-pin', label: location),
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
                      Text('CANCELLED', style: FraternusTypography.eyebrow(color: FraternusColors.error))
                    else if (startingSoonLabel != null)
                      Tag(label: startingSoonLabel, size: TagSize.small),
                    const SizedBox(height: 20),
                    const FraternusIcon(name: 'chevron-right', size: 18, opacity: 0.5),
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
          child: Text(label, style: FraternusTypography.small(color: FraternusColors.textOnLightMuted)),
        ),
      ],
    );
  }
}
