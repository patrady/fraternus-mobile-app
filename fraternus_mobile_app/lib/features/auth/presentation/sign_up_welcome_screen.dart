import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../design_system/design_system.dart';

/// The unauthenticated app's entry point (see the router's `redirect` in
/// app/router/app_router.dart) — offers Create Account or Sign In, nothing
/// else.
class SignUpWelcomeScreen extends StatelessWidget {
  const SignUpWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      dark: true,
      footer: Column(
        children: [
          Button(
            label: 'Create Account',
            fullWidth: true,
            size: ButtonSize.large,
            onPressed: () => context.push(RoutePaths.signUp),
          ),
          const SizedBox(height: 16),
          Button(
            label: 'Sign In',
            variant: ButtonVariant.ghost,
            size: ButtonSize.large,
            onDark: true,
            onPressed: () => context.push(RoutePaths.signIn),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 140),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const FraternusIcon(name: 'shield', size: 34, tone: FraternusIconTone.white),
                const SizedBox(width: 10),
                Text(
                  'fraternus',
                  style: FraternusTypography.h2(color: FraternusColors.textOnDark).copyWith(fontSize: 30),
                ),
              ],
            ),
            const SizedBox(height: 40),
            const Heading(
              'BUILDING BROTHERHOOD. STRENGTHENING FATHERS.',
              level: HeadingLevel.h2,
              onDark: true,
              align: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const BodyText(
              'Prayer, mentoring, and formation for young men and the fathers who raise them.',
              onDark: true,
              align: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
