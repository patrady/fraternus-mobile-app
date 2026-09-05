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
    final userAsync = ref.watch(currentUserProvider);
    final remindersAsync = ref.watch(profileRemindersProvider);

    return ScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Reminders', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: userAsync.when(
              data: (user) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Box(
                    child: ListRow(
                      label: 'All Reminders',
                      bordered: false,
                      trailing: FraternusSwitch(
                        value: user.isRemindersEnabled,
                        onChanged: (_) => ref
                            .read(currentUserProvider.notifier)
                            .toggleRemindersEnabled(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  remindersAsync.when(
                    data: (groups) => _RemindersList(
                      groups: groups,
                      enabled: user.isRemindersEnabled,
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (error, stackTrace) => const BodyText(
                      'Something went wrong loading reminders.',
                    ),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) =>
                  const BodyText('Something went wrong loading reminders.'),
            ),
          ),
        ],
      ),
    );
  }
}

class _RemindersList extends ConsumerWidget {
  const _RemindersList({required this.groups, required this.enabled});

  final List<ReminderGroup> groups;

  /// The master switch — individual toggles below still reflect their own
  /// per-type state, but are disabled (can't be edited) while the master
  /// switch is off, since none of them would fire regardless.
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final group in groups) ...[
            Text(
              group.title.toUpperCase(),
              style: FraternusTypography.eyebrow(
                color: FraternusColors.accentPrimary,
              ),
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
                        onChanged: enabled
                            ? (_) => ref
                                  .read(profileRemindersProvider.notifier)
                                  .toggle(group.reminders[i].type)
                            : (_) {},
                      ),
                    ),
                    if (i != group.reminders.length - 1)
                      const HairlineDivider(),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}
