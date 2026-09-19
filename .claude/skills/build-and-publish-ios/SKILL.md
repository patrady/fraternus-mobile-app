---
name: build-and-publish-ios
description: Build a release iOS IPA for the Fraternus app and upload it to App Store Connect/TestFlight via altool. Use when the user asks to push, upload, or ship a new iOS build to TestFlight or the App Store.
---

# App Store / TestFlight upload

Builds `fraternus_mobile_app` in release mode and uploads it to App Store Connect (TestFlight) using an App Store Connect API key.

## Steps

1. Run `fraternus_mobile_app/scripts/upload_testflight.sh` from the repo root.
   - It builds the release IPA (`flutter build ipa --dart-define-from-file=env/prod.json`) and uploads it with `xcrun altool --upload-app`.
   - It reads the API Key ID / Issuer ID from `fraternus_mobile_app/env/testflight.json` (gitignored, template at `env/testflight.example.json`).
2. If altool reports the build number has already been used, bump the `+N` build number in `fraternus_mobile_app/pubspec.yaml`'s `version:` line and rerun the script.
3. Report the upload result back to the user, including any `server_warning`s altool prints even on a successful upload (e.g. minimum OS version requirements) — these don't block the upload but are worth surfacing.

## Notes

- This uploads a real build to Apple and is visible in App Store Connect/TestFlight — only run it when the user explicitly asks to push/ship/upload a build, not proactively.
- Processing on Apple's side takes a few minutes after a successful upload; the build then needs to finish processing before it's testable in TestFlight.
