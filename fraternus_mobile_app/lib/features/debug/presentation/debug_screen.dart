import 'package:flutter/material.dart'
    show TimeOfDay, showDatePicker, showTimePicker;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../app/clock_provider.dart';
import '../../../design_system/design_system.dart';

final _dateTimeLabel = DateFormat('EEE, MMM d, yyyy \u{2022} h:mm a');

const _quickOffsets = [
  (label: '-1 Week', offset: Duration(days: -7)),
  (label: '-1 Day', offset: Duration(days: -1)),
  (label: '+1 Day', offset: Duration(days: 1)),
  (label: '+1 Week', offset: Duration(days: 7)),
];

/// Debug-only tab (see [kDebugMode] gating in app_shell.dart/app_router.dart)
/// for previewing Today/Challenges/Events/Field Guide as of a fake "now"
/// instead of the real wall clock — see [nowProvider]'s doc comment for
/// what this can and can't fake. Only reachable once unlocked (see
/// debug_unlock_provider.dart) — app_router.dart's redirect bounces any
/// other attempt to reach this route back to Today, so this screen itself
/// doesn't need its own lock check.
class DebugScreen extends ConsumerWidget {
  const DebugScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final override = ref.watch(appClockProvider);
    final effectiveNow = ref.watch(nowProvider);
    final notifier = ref.read(appClockProvider.notifier);

    return ScreenShell(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Heading('DEBUG', level: HeadingLevel.h2),
            const SizedBox(height: 20),
            Box(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BodyText(
                    override == null ? 'Using real time' : 'Overridden',
                    size: BodyTextSize.small,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _dateTimeLabel.format(effectiveNow),
                    style: FraternusTypography.h4(color: FraternusColors.ink),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const BodyText('Jump', size: BodyTextSize.small),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final quick in _quickOffsets)
                  Button(
                    label: quick.label,
                    size: ButtonSize.small,
                    variant: ButtonVariant.ghost,
                    onPressed: () =>
                        notifier.overrideNow(effectiveNow.add(quick.offset)),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Button(
              label: 'Pick a date & time',
              fullWidth: true,
              variant: ButtonVariant.ghost,
              onPressed: () async {
                final pickedDate = await showDatePicker(
                  context: context,
                  initialDate: effectiveNow,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (pickedDate == null || !context.mounted) return;
                final pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(effectiveNow),
                );
                if (pickedTime == null) return;
                notifier.overrideNow(
                  DateTime(
                    pickedDate.year,
                    pickedDate.month,
                    pickedDate.day,
                    pickedTime.hour,
                    pickedTime.minute,
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Button(
              label: 'Reset to real time',
              fullWidth: true,
              variant: ButtonVariant.ghost,
              disabled: override == null,
              onPressed: notifier.reset,
            ),
            const SizedBox(height: 20),
            const BodyText(
              'Overriding "now" changes what Today, Challenges, Events, and '
              'Field Guide consider current — including which Frat Night is '
              'active and which challenge is shown. It cannot fake '
              "timestamps the backend itself stamps (e.g. a rep's completed "
              'date), so those still reflect the real time once a write '
              'round-trips.',
              size: BodyTextSize.caption,
            ),
          ],
        ),
      ),
    );
  }
}
