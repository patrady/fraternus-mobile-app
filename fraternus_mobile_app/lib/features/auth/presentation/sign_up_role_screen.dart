import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/router/route_paths.dart';
import '../../../design_system/design_system.dart';
import '../providers/auth_providers.dart';

enum _SignUpRole { parentOrVolunteer, brother }

/// First step of signup — app_concept.md's Profile section: "the user must
/// choose between two options: Captain or Guardian." Both collapse into a
/// single "Parent or Volunteer" choice here — the wizard behind it
/// (SignUpAccountScreen) determines Captain vs. Guardian itself via its
/// "will you be attending weekly frat nights" step. Brother is shown but
/// disabled — app_concept.md: "Brothers cannot sign up for their own
/// account yet."
class SignUpRoleScreen extends ConsumerStatefulWidget {
  const SignUpRoleScreen({super.key});

  @override
  ConsumerState<SignUpRoleScreen> createState() => _SignUpRoleScreenState();
}

class _SignUpRoleScreenState extends ConsumerState<SignUpRoleScreen> {
  _SignUpRole? _selected;

  void _continue() {
    if (_selected == _SignUpRole.brother) {
      context.push(RoutePaths.signUpBrother);
      return;
    }

    // Flips the router redirect's wizard exemption on — see
    // signUpWizardActiveProvider's doc comment — before pushing, so
    // the wizard survives becoming signed-in partway through it
    // without disturbing normal push/pop back navigation here.
    ref.read(signUpWizardActiveProvider.notifier).set(true);

    context.push(RoutePaths.signUpAccount);
  }

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      footer: Button(
        label: 'Continue',
        icon: 'chevron-right',
        iconPosition: ButtonIconPosition.right,
        fullWidth: true,
        disabled: _selected == null,
        onPressed: _continue,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Create Account', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                const BodyText('Which describes you?'),
                const SizedBox(height: 20),
                SelectableCard(
                  icon: 'circle-user',
                  title: 'Parent or Captain',
                  description: "Adult (18+)",
                  selected: _selected == _SignUpRole.parentOrVolunteer,
                  onPressed: () => setState(() => _selected = _SignUpRole.parentOrVolunteer),
                ),
                SelectableCard(
                  icon: 'circle-user',
                  title: 'Brother',
                  description: "Young Man",
                  selected: _selected == _SignUpRole.brother,
                  onPressed: () => setState(() => _selected = _SignUpRole.brother),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
