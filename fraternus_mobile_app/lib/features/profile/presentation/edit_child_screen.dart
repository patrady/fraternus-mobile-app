import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../../shared/models/chapter.dart';
import '../../../shared/providers/chapter_providers.dart';
import '../models/member.dart';
import '../providers/profile_providers.dart';
import 'widgets/child_form.dart';

class EditChildScreen extends ConsumerWidget {
  const EditChildScreen({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(householdMembersProvider);
    final chapters = ref.watch(chaptersProvider).value ?? const <Chapter>[];

    return ScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Edit Child', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: membersAsync.when(
              data: (members) {
                Member? member;
                for (final m in members) {
                  if (m.id == memberId) {
                    member = m;
                    break;
                  }
                }
                if (member == null) {
                  return const BodyText('This child could not be found.');
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ChildForm(
                      initial: member,
                      chapters: chapters,
                      onSave:
                          ({
                            required firstName,
                            required lastName,
                            required email,
                            required chapterKey,
                          }) async {
                            await ref
                                .read(householdMembersProvider.notifier)
                                .updateMember(
                                  member!.copyWith(
                                    firstName: firstName,
                                    lastName: lastName,
                                    email: email,
                                    clearEmail: email == null,
                                    chapterKey: chapterKey,
                                  ),
                                );
                            if (context.mounted) context.pop();
                          },
                      onRemove: () async {
                        // docs/adrs/003_coppa_child_data_deletion.md — this
                        // is a full, permanent COPPA data-deletion request,
                        // not a simple list removal, so the confirmation
                        // says so explicitly rather than just "remove".
                        final confirmed = await showFraternusConfirmDialog(
                          context: context,
                          title: 'Delete Child Data',
                          message:
                              "This will permanently delete ${member!.fullName}'s data — every reading, "
                              'challenge, and RSVP recorded for them. This cannot be undone.',
                          confirmLabel: 'Delete',
                        );
                        if (!confirmed || !context.mounted) return;
                        await ref
                            .read(householdMembersProvider.notifier)
                            .remove(memberId);
                        if (context.mounted) context.pop();
                      },
                    ),
                  ],
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) =>
                  const BodyText('Something went wrong loading this child.'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
