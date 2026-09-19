---
name: build-and-publish-android
description: Build a signed production Android release bundle (.aab) for Fraternus and walk through publishing it to the Google Play Console internal testing track. Use when asked to build/ship/release/publish an Android build, cut a new Play Store internal testing version, or upload to Play Console.
---

## Prerequisites (check before building)

- `android/key.properties` and the keystore it points at must exist — without them the build falls back to debug signing, which still installs but isn't a real release artifact. If missing, stop and tell the user to generate a keystore themselves (`keytool -genkeypair`, run by them so passwords never pass through chat) and create `key.properties` — don't generate secrets on their behalf.
- `env/prod.json` must exist and hold the real hosted Supabase URL/anon key — **never** build a release with `env/local.json` (that file has been repointed at `10.0.2.2` for local Android-emulator testing in the past, and shipping that is a silent, hard-to-diagnose production outage: the app fails before any request reaches the server, so nothing shows up in Supabase logs).

## Steps

1. **Bump the build number** in `fraternus_mobile_app/pubspec.yaml`'s `version:` line (the part after `+`). Play Console rejects re-uploading an already-used version code — check `git log -p -- pubspec.yaml` or ask the user what's currently live if unsure. Don't bump the version *name* (the part before `+`) unless the user asked for a real version bump, not just a new build.

2. **Build the release bundle** — from `fraternus_mobile_app/`:
   ```
   mise exec -- flutter build appbundle --release --dart-define-from-file=env/prod.json
   ```
   Do **not** build via a raw `./gradlew bundleRelease`/`assembleRelease` call — it bypasses Flutter's dart-define mechanism entirely, silently producing a build with empty `SUPABASE_URL`/`SUPABASE_ANON_KEY` (see `lib/app/env.dart`'s `String.fromEnvironment` defaults). This exact mistake shipped a broken build to production once already.

3. **Verify signing** — confirm it's signed with the real upload key, not the debug fallback:
   ```
   mise exec -- keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
   ```
   The `Owner`/`Issuer` should match the project's real keystore identity, not the generic Android Debug certificate.

4. **Verify the prod config actually got embedded** — extract and grep the compiled native library for the real Supabase project ref (catches the exact silent-failure mode from step 2):
   ```
   cd /tmp && rm -rf aab_check && mkdir aab_check && cd aab_check
   unzip -o -q <path-to-aab> "base/lib/arm64-v8a/libapp.so"
   strings base/lib/arm64-v8a/libapp.so | grep -o "supabase\.co" | head -1
   cd / && rm -rf /tmp/aab_check
   ```
   If nothing matches, the dart-defines didn't make it in — stop and re-check step 2's command.

5. **Report the artifact** — path (`build/app/outputs/bundle/release/app-release.aab`), size, and version — then hand off to the manual publish steps below. Do not attempt to upload it yourself: it's reliably well over the 10MB limit on browser-automation file uploads, so this step is on the user.

## Publishing to Play Console (tell the user these steps)

1. [Play Console](https://play.google.com/console) → the app → **Testing → Internal testing** → **Create new release**.
2. Upload `app-release.aab` from the path reported above.
3. Fill in release notes (required even for internal testing).
4. **Next → Save → Review release → Start rollout to Internal testing.**

## Known build failures and fixes (already applied in this repo — only relevant if they regress or a fresh machine hits them)

- **"Release app bundle failed to strip debug symbols from native libraries"** — usually a false positive: Flutter's post-build verification needs `apkanalyzer` from the Android SDK's cmdline-tools, and silently treats "couldn't verify" as "failed" when cmdline-tools is missing. Fix: install cmdline-tools (`https://developer.android.com/studio#command-line-tools-only`) into `$ANDROID_HOME/cmdline-tools/latest/`, then `sdkmanager --licenses`. Confirm with `flutter doctor -v` showing a clean Android toolchain.
- **Gradle crashes with a bare version number as the error** (e.g. `IllegalArgumentException: 25.0.x`) — Gradle 8.14's Kotlin DSL compiler can't parse very new JDK version strings. Fix is already in place: `flutter config --jdk-dir` points at a JDK 24 install instead of Android Studio's bundled JBR. If this regresses, re-run `flutter config --jdk-dir=<path-to-a-jdk-24-or-similar>`.
- **R8 fails on missing `androidx.window.sidecar`/`androidx.window.extensions` classes** — already fixed via `android/app/proguard-rules.pro` (`-dontwarn` rules) wired into `android/app/build.gradle.kts`'s `proguardFiles`. If a fresh proguard file ever loses these rules, that's the fix to restore.
- **`configureCMakeDebug`/cmake shim errors ("no version is set")** — this repo pins `cmake`/`java`/`node`/`flutter` via `mise.toml` at the repo root; running through `mise exec --` (as all commands above do) avoids this entirely.
