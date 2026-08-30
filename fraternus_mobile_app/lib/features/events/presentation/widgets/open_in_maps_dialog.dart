import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../design_system/design_system.dart';
import '../../models/event_location.dart';

/// Prompts the user to open [location] in Apple Maps or Google Maps.
///
/// Both options are plain `https` universal links rather than custom URL
/// schemes (`comgooglemaps://`, `maps://`) — that needs no
/// `LSApplicationQueriesSchemes`/Android `<queries>` entitlement wiring, and
/// each link falls back to the map provider's website if the app isn't
/// installed. Apple Maps is only offered on iOS, since there's no Apple
/// Maps app (or a meaningful place for that link to go) on Android.
Future<void> showOpenInMapsPrompt(
  BuildContext context,
  EventLocation location,
) {
  final query = Uri.encodeComponent(location.mapQuery);
  final isIOS = defaultTargetPlatform == TargetPlatform.iOS;

  return showDialog<void>(
    context: context,
    barrierColor: const Color(0x66000000),
    builder: (context) {
      return Dialog(
        backgroundColor: FraternusColors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(FraternusRadii.lg)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isIOS) ...[
                Button(
                  label: 'Open in Apple Maps',
                  variant: ButtonVariant.primary,
                  fullWidth: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    launchUrl(
                      Uri.parse('https://maps.apple.com/?q=$query'),
                      mode: LaunchMode.externalApplication,
                    );
                  },
                ),
                const SizedBox(height: 10),
              ],
              Button(
                label: 'Open in Google Maps',
                variant: ButtonVariant.primary,
                fullWidth: true,
                onPressed: () {
                  Navigator.of(context).pop();
                  launchUrl(
                    Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=$query',
                    ),
                    mode: LaunchMode.externalApplication,
                  );
                },
              ),
              const SizedBox(height: 10),
              Button(
                label: 'Cancel',
                variant: ButtonVariant.ghost,
                fullWidth: true,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      );
    },
  );
}
