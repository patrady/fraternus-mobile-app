import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import '../../../shared/models/chapter.dart';
import '../../../shared/providers/chapter_providers.dart';
import '../models/member.dart';
import '../models/user_member_association.dart';
import '../providers/profile_providers.dart';
import 'widgets/child_form.dart';

class EditChildScreen extends ConsumerWidget {
  const EditChildScreen({super.key, required this.memberId});

  final String memberId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(householdMembersProvider);
    final associationsAsync = ref.watch(householdAssociationsProvider);
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
                if (member == null) return const BodyText('This child could not be found.');

                UserMemberAssociation? association;
                for (final a in associationsAsync.value ?? const <UserMemberAssociation>[]) {
                  if (a.memberId == memberId && a.relationship == AssociationRelationship.guardian) {
                    association = a;
                    break;
                  }
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Only Members under 13 with a Guardian association have
                    // a consent status at all — see app_concept.md's
                    // COPPA/Consent section.
                    if (association?.consentStatus != null) ...[
                      _ConsentSection(memberId: memberId, association: association!),
                      const SizedBox(height: 16),
                    ],
                    ChildForm(
                      initial: member,
                      chapters: chapters,
                      onSave: ({required firstName, required lastName, required birthday, required email, required chapterKey}) async {
                        await ref
                            .read(householdMembersProvider.notifier)
                            .updateMember(
                              member!.copyWith(
                                firstName: firstName,
                                lastName: lastName,
                                birthday: birthday,
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
                        await ref.read(householdMembersProvider.notifier).remove(memberId);
                        if (context.mounted) context.pop();
                      },
                    ),
                  ],
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

/// app_concept.md's COPPA/Consent section: a Guardian can revoke consent at
/// any time, "treated as a request to stop all further data collection for
/// that Member." Granting consent is a separate, not-yet-designed
/// verification flow (see docs/adrs/002_supabase_backend_poc.md §5) — this
/// only covers display + revocation.
class _ConsentSection extends ConsumerWidget {
  const _ConsentSection({required this.memberId, required this.association});

  final String memberId;
  final UserMemberAssociation association;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = association.consentStatus!;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FraternusColors.white,
        border: Border.all(color: FraternusColors.borderSubtle),
        borderRadius: BorderRadius.circular(FraternusRadii.lg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FieldLabel(label: 'Guardian Consent'),
              const Spacer(),
              Tag(
                label: status.name,
                color: status == ConsentStatus.granted ? TagColor.primary : TagColor.secondary,
              ),
            ],
          ),
          const SizedBox(height: 4),
          const BodyText(
            'Required by COPPA for members under 13 before any reading, challenge, or event data '
            'can be recorded on their behalf.',
            size: BodyTextSize.small,
          ),
          if (status == ConsentStatus.granted) ...[
            const SizedBox(height: 12),
            Button(
              label: 'Revoke Consent',
              variant: ButtonVariant.ghost,
              color: ButtonColor.danger,
              fullWidth: true,
              onPressed: () async {
                final confirmed = await showFraternusConfirmDialog(
                  context: context,
                  title: 'Revoke Consent',
                  message:
                      'This stops all further data collection for this child — no new readings, '
                      'challenges, or event data can be recorded on their behalf until consent is '
                      'granted again.',
                  confirmLabel: 'Revoke',
                );
                if (!confirmed) return;
                await ref.read(profileRepositoryProvider).revokeConsent(memberId);
                ref.invalidate(householdAssociationsProvider);
              },
            ),
          ],
        ],
      ),
    );
  }
}
