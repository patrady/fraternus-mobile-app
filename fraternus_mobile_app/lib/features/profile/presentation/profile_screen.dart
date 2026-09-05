import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../design_system/design_system.dart';
import '../../auth/providers/auth_providers.dart';
import '../../guide/models/temperament.dart';
import '../../guide/providers/guide_providers.dart';
import '../models/app_user.dart';
import '../models/member.dart';
import '../providers/profile_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return ScreenShell(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: userAsync.when(
          data: (user) => _ProfileContent(user: user),
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) =>
              const BodyText('Something went wrong loading your profile.'),
        ),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  const _ProfileContent({required this.user});

  final AppUser user;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // No Member record (a Guardian who has never attended as a Captain) —
    // there's nothing to take the quiz as, so the temperament section below
    // is skipped entirely rather than keying off a nonexistent Member id.
    final Member? selfMember = ref.watch(selfMemberProvider).value;
    final temperamentResult = selfMember == null
        ? null
        : ref.watch(guideTemperamentResultProvider(selfMember.id)).value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            PressableBuilder(
              onTap: () => context.pop(),
              semanticLabel: 'Back',
              builder: (context, isPressed) {
                return Opacity(
                  opacity: isPressed ? 0.75 : 1,
                  child: const SizedBox(
                    height: 44,
                    width: 32,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FraternusIcon(name: 'chevron-left', size: 22),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(width: 4),
            const Heading('PROFILE', level: HeadingLevel.h2),
          ],
        ),
        const SizedBox(height: 20),
        ListRow(
          leading: Avatar(initials: user.initials, size: AvatarSize.small),
          label: user.fullName,
          onPressed: () => context.push(RoutePaths.todayProfileEdit),
        ),
        ListRow(
          leading: const FraternusIcon(name: 'users', size: 20),
          label: 'My Kids',
          onPressed: () => context.push(RoutePaths.todayProfileKids),
        ),
        ListRow(
          leading: const FraternusIcon(name: 'bell', size: 20),
          label: 'Reminders',
          onPressed: () => context.push(RoutePaths.todayProfileReminders),
        ),
        const SizedBox(height: 8),
        if (selfMember != null) ...[
          if (temperamentResult != null)
            DarkFeatureCard(
              icon: 'compass',
              eyebrow: 'Your Temperament',
              value: temperamentDisplayNames[temperamentResult.primaryKey],
              ctaLabel: 'Take Again',
              onCta: () =>
                  context.push(RoutePaths.temperamentQuiz(selfMember.id)),
            )
          else
            Button(
              label: 'Find Your Temperament',
              fullWidth: true,
              onPressed: () =>
                  context.push(RoutePaths.temperamentQuiz(selfMember.id)),
            ),
          const SizedBox(height: 20),
        ],
        Button(
          label: 'Log Out',
          variant: ButtonVariant.ghost,
          color: ButtonColor.danger,
          fullWidth: true,
          onPressed: () async {
            final confirmed = await showFraternusConfirmDialog(
              context: context,
              title: 'Log Out',
              message: 'Are you sure you want to log out?',
              confirmLabel: 'Log Out',
            );
            // The router's redirect (re-evaluated via authStateChanges,
            // see app/router/app_router.dart) sends the app to sign-in as
            // soon as the session clears — no explicit navigation needed.
            if (confirmed) await ref.read(authRepositoryProvider).signOut();
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
