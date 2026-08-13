import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../models/reminder_setting.dart';
import '../providers/profile_providers.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final remindersAsync = ref.watch(profileRemindersProvider);

    return ScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Reminders', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: remindersAsync.when(
              data: (groups) => _RemindersList(groups: groups),
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) => const BodyText('Something went wrong loading reminders.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemindersList extends ConsumerWidget {
  const _RemindersList({required this.groups});

  final List<ReminderGroup> groups;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in groups) ...[
          Text(
            group.title.toUpperCase(),
            style: FraternusTypography.eyebrow(color: FraternusColors.accentPrimary),
          ),
          const SizedBox(height: 8),
          Box(
            child: Column(
              children: [
                for (var i = 0; i < group.reminders.length; i++) ...[
                  ListRow(
                    label: group.reminders[i].label,
                    sublabel: group.reminders[i].timeLabel,
                    bordered: false,
                    trailing: FraternusSwitch(
                      value: group.reminders[i].enabled,
                      onChanged: (_) =>
                          ref.read(profileRemindersProvider.notifier).toggle(group.reminders[i].id),
                    ),
                  ),
                  if (i != group.reminders.length - 1) const HairlineDivider(),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}
