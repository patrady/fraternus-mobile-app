import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';

class SignUpBrotherBlockedScreen extends StatelessWidget {
  const SignUpBrotherBlockedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ScreenHeader(title: 'Brother', onBack: () => context.pop()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 32),
                const IconBadgeCircle(
                  icon: 'triangle-alert',
                  size: IconBadgeCircleSize.large,
                  color: IconBadgeCircleColor.secondary,
                ),
                const SizedBox(height: 20),
                const Heading('WE LOVE THE ENTHUSIASM', level: HeadingLevel.h3, align: TextAlign.center),
                const SizedBox(height: 12),
                const BodyText(
                  "As a minor, you can't create your own account. Ask your parent or "
                  'guardian to create their account and add you. After that, they can '
                  'send you an invite to sign up.',
                  align: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
