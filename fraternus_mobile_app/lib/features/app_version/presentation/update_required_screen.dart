import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/env.dart';
import '../../../design_system/design_system.dart';
import '../providers/app_version_providers.dart';

const _defaultMessage =
    "This version of the app is no longer supported. Please update to the latest version.";

/// Full-screen, non-dismissible lockout shown when the boot-time check
/// (see app_version_providers.dart) finds the running version deprecated
/// or below the platform's minimum — reachable regardless of auth state
/// (see app_router.dart's redirect, which checks this before the auth
/// guard). No back button, no way to navigate away: [PopScope] blocks the
/// Android hardware back gesture, and the router bounces any other
/// location back here as long as the app is blocked.
class UpdateRequiredScreen extends ConsumerWidget {
  const UpdateRequiredScreen({super.key});

  /// Null until Env's store identifiers are set (e.g. in `flutter test`,
  /// or before the app has a real store listing) — see env.dart.
  static Uri? _storeUri() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      if (Env.storeIosAppId.isEmpty) return null;
      return Uri.parse('https://apps.apple.com/app/id${Env.storeIosAppId}');
    }
    if (Env.storeAndroidPackageId.isEmpty) return null;
    return Uri.parse(
      'https://play.google.com/store/apps/details?id=${Env.storeAndroidPackageId}',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(appVersionStatusProvider);
    final storeUri = _storeUri();

    return PopScope(
      canPop: false,
      // scrollable: false hands `child` the shell's full remaining height
      // (rather than shrink-wrapping it in a SingleChildScrollView), which
      // is what lets Center below actually center — a scroll view sizes
      // its child to its own intrinsic height instead.
      child: ScreenShell(
        scrollable: false,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const IconBadgeCircle(
                  icon: 'triangle-alert',
                  size: IconBadgeCircleSize.large,
                  color: IconBadgeCircleColor.secondary,
                ),
                const SizedBox(height: 20),
                const Heading(
                  'UPDATE REQUIRED',
                  level: HeadingLevel.h3,
                  align: TextAlign.center,
                ),
                const SizedBox(height: 12),
                BodyText(
                  status.message ?? _defaultMessage,
                  align: TextAlign.center,
                ),
                if (storeUri != null) ...[
                  const SizedBox(height: 24),
                  Button(
                    label: 'Update Now',
                    variant: ButtonVariant.primary,
                    fullWidth: true,
                    onPressed: () => launchUrl(
                      storeUri,
                      mode: LaunchMode.externalApplication,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
