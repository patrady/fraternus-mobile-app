import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../models/member.dart';
import '../providers/profile_providers.dart';
import 'widgets/child_form.dart';

class EditChildScreen extends ConsumerWidget {
  const EditChildScreen({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(householdMembersProvider);

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
                if (member == null) return const BodyText('This child could not be found.');

                return ChildForm(
                  initial: member,
                  onSave: ({required firstName, required lastName, required birthday, required email, required chapterId}) {
                    ref
                        .read(householdMembersProvider.notifier)
                        .upsert(
                          member!.copyWith(
                            firstName: firstName,
                            lastName: lastName,
                            birthday: birthday,
                            email: email,
                            clearEmail: email == null,
                            chapterId: chapterId,
                          ),
                        );
                    context.pop();
                  },
                  onRemove: () async {
                    final confirmed = await showFraternusConfirmDialog(
                      context: context,
                      title: 'Remove Child',
                      message: 'Are you sure you want to remove ${member!.fullName}? This cannot be undone.',
                      confirmLabel: 'Remove',
                    );
                    if (!confirmed || !context.mounted) return;
                    ref.read(householdMembersProvider.notifier).remove(memberId);
                    ref.read(householdAssociationsProvider.notifier).remove(memberId);
                    context.pop();
                  },
                );
              },
              loading: () => const SizedBox.shrink(),
              error: (error, stackTrace) => const BodyText('Something went wrong loading this child.'),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
