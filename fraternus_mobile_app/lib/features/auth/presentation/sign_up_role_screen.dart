import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../design_system/design_system.dart';

/// First step of signup — app_concept.md's Profile section: "the user must
/// choose between two options: Captain or Guardian."
class SignUpRoleScreen extends StatelessWidget {
  const SignUpRoleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Sign Up', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const BodyText('Which best describes you?'),
                const SizedBox(height: 20),
                SelectableCard(
                  icon: 'award',
                  title: 'Captain',
                  description: 'An adult mentor or leader involved with Fraternus.',
                  onPressed: () => context.push(RoutePaths.signUpCaptain),
                ),
                SelectableCard(
                  icon: 'users',
                  title: 'Guardian',
                  description: "A parent with a child (or children) in Fraternus.",
                  onPressed: () => context.push(RoutePaths.signUpGuardian),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
